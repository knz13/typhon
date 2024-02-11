#pragma once
#include <iostream>
#include <fstream>
#include <streambuf>
#include <sstream>
#include <string>
#include <vector>
#include <algorithm>
#include "../vendor/crunch/crunch/tinydir.h"
#include "../vendor/crunch/crunch/bitmap.hpp"
#include "../vendor/crunch/crunch/packer.hpp"
#include "../vendor/crunch/crunch/binary.hpp"
#include "../vendor/crunch/crunch/hash.hpp"


using namespace std;

class PathStrConversion {
public:
    static const string& StrToPath(const string& str)
    {
        return str;
    }
    static const string& PathToStr(const string& str)
    {
        return str;
    }

};


struct TextureAtlasImageProperties {
    int width;
    int height;
    std::string name;
    int xPos;
    int yPos;

    TextureAtlasImageProperties(std::string name,int width,int height,int xpos,int ypos) : name(name),width(width),height(height),xPos(xpos),yPos(ypos) {};

    TextureAtlasImageProperties() : width(0),height(0),xPos(0),yPos(0),name("") {};
};

namespace Crunch {

    enum CrunchOptions {
        optNone = 0,
        optXml = 1,
        optBinary = 2,
        optJson = 4,
        optPremultiply = 8,
        optTrim = 16,
        optVerbose = 32,
        optForce = 64,
        optUnique = 128,
        optRotate = 256
    };



    static void SplitFileName(const string& path, string* dir, string* name, string* ext)
    {
        size_t si = path.rfind('/') + 1;
        if (si == string::npos)
            si = 0;
        size_t di = path.rfind('.');
        if (dir != nullptr)
        {
            if (si > 0)
                *dir = path.substr(0, si);
            else
                *dir = "";
        }
        if (name != nullptr)
        {
            if (di != string::npos)
                *name = path.substr(si, di - si);
            else
                *name = path.substr(si);
        }
        if (ext != nullptr)
        {
            if (di != string::npos)
                *ext = path.substr(di);
            else
                *ext = "";
        }
    }

    static string GetFileName(const string& path)
    {
        string name;
        SplitFileName(path, nullptr, &name, nullptr);
        return name;
    }

    static void LoadSingleBitmap(std::vector<Bitmap*>& bitmaps,const string& prefix, const std::string& path,int options = CrunchOptions::optNone)
    {
        if (options & CrunchOptions::optVerbose)
            cout << '\t' << PathStrConversion::PathToStr(path) << endl;
        
        bitmaps.push_back(new Bitmap(PathStrConversion::PathToStr(path), prefix + GetFileName(PathStrConversion::PathToStr(path)),options & CrunchOptions::optPremultiply,options & CrunchOptions::optTrim));
    }

    static void LoadBitmaps(std::vector<Bitmap*>& bitmaps,const string& root, const string& prefix,int options = CrunchOptions::optNone)
    {
        static string dot1 = ".";
        static string dot2 = "..";
        
        tinydir_dir dir;
        tinydir_open(&dir, PathStrConversion::StrToPath(root).data());
        
        while (dir.has_next)
        {
            tinydir_file file;
            tinydir_readfile(&dir, &file);
            
            if (file.is_dir)
            {
                if (dot1 != PathStrConversion::PathToStr(file.name) && dot2 != PathStrConversion::PathToStr(file.name))
                    LoadBitmaps(bitmaps,PathStrConversion::PathToStr(file.path), prefix + PathStrConversion::PathToStr(file.name) + "/");
            }
            else if (PathStrConversion::PathToStr(file.extension) == "png")
                LoadSingleBitmap(bitmaps,prefix, file.path);
            
            tinydir_next(&dir);
        }
        
        tinydir_close(&dir);
    }

    static void RemoveFile(string file)
    {
        remove(file.data());
    }

    static int GetPackSize(const string& str)
    {
        if (str == "4096")
            return 4096;
        if (str == "2048")
            return 2048;
        if (str == "1024")
            return 1024;
        if (str == "512")
            return 512;
        if (str == "256")
            return 256;
        if (str == "128")
            return 128;
        if (str == "64")
            return 64;
        return -1;
    }

    static int GetPadding(const string& str)
    {
        for (int i = 0; i <= 16; ++i)
            if (str == to_string(i))
                return i;
        cerr << "invalid padding value: " << str << endl;
        return -1;
    }




    static bool PackFromFolder(std::vector<std::string> inputs,std::string outputDir,std::string name,int options = CrunchOptions::optNone) {


        vector<Bitmap*> bitmaps;
        vector<Packer*> packers;

        
        //Get the options
        int optSize = 4096;
        int optPadding = 1;

        size_t newHash = 0;
        HashString(newHash, outputDir);
        for (size_t i = 0; i < inputs.size(); ++i)
        {
            if (inputs[i].rfind('.') == string::npos)
                HashFiles(newHash, inputs[i]);
            else
                HashFile(newHash, inputs[i]);
        }


        size_t oldHash;
        if (LoadHash(oldHash, outputDir + name + ".hash"))
        {
            if (!(options & CrunchOptions::optForce) && newHash == oldHash)
            {
                cout << "atlas is unchanged: " << name << endl;
                return true;
            }
        }
        

        RemoveFile(outputDir + name + ".hash");
        RemoveFile(outputDir + name + ".bin");
        RemoveFile(outputDir + name + ".xml");
        RemoveFile(outputDir + name + ".json");

        

        for (size_t i = 0; i < inputs.size(); ++i)
        {
            if (inputs[i].rfind('.') != string::npos)
                LoadSingleBitmap(bitmaps,"", PathStrConversion::StrToPath(inputs[i]));
            else
                LoadBitmaps(bitmaps,inputs[i], "");
        }

        sort(bitmaps.begin(), bitmaps.end(), [](const Bitmap* a, const Bitmap* b) {
            return (a->width * a->height) < (b->width * b->height);
        });

        while (!bitmaps.empty())
        {
            if (options & CrunchOptions::optVerbose)
                cout << "packing " << bitmaps.size() << " images..." << endl;
            auto packer = new Packer(optSize, optSize, optPadding);
            packer->Pack(bitmaps, options & CrunchOptions::optVerbose, options & CrunchOptions::optUnique,options & CrunchOptions::optRotate);
            packers.push_back(packer);
            if (options & CrunchOptions::optVerbose)
                cout << "finished packing: " << name << to_string(packers.size() - 1) << " (" << packer->width << " x " << packer->height << ')' << endl;
        
            if (packer->bitmaps.empty())
            {
                cerr << "packing failed, could not fit bitmap: " << (bitmaps.back())->name << endl;
                return false;
            }
        }

        for (size_t i = 0; i < packers.size(); ++i)
        {
            if (options & CrunchOptions::optVerbose)
                cout << "writing png: " << outputDir << name << to_string(i) << ".png" << endl;
            packers[i]->SavePng(outputDir + name + to_string(i) + ".png");
        }
        
        //Save the atlas binary
        if (options & CrunchOptions::optBinary)
        {
            if (options & CrunchOptions::optVerbose)
                cout << "writing bin: " << outputDir << name << ".bin" << endl;
            
            ofstream bin(outputDir + name + ".bin", ios::binary);
            WriteShort(bin, (int16_t)packers.size());
            for (size_t i = 0; i < packers.size(); ++i)
                packers[i]->SaveBin(name + to_string(i), bin,options & CrunchOptions::optTrim,options & CrunchOptions::optRotate);
            bin.close();
        }
        
        //Save the atlas xml
        if (options & CrunchOptions::optXml)
        {
            if (options & CrunchOptions::optVerbose)
                cout << "writing xml: " << outputDir << name << ".xml" << endl;
            
            ofstream xml(outputDir + name + ".xml");
            xml << "<atlas>" << endl;
            for (size_t i = 0; i < packers.size(); ++i)
                packers[i]->SaveXml(name + to_string(i), xml,options & CrunchOptions::optTrim,options & CrunchOptions::optRotate);
            xml << "</atlas>";
        }
        
        //Save the atlas json
        if (options & CrunchOptions::optJson)
        {
            if (options & CrunchOptions::optVerbose)
                cout << "writing json: " << outputDir << name << ".json" << endl;
            
            ofstream json(outputDir + name + ".json");
            json << '{' << endl;
            json << "\t\"textures\":[" << endl;
            for (size_t i = 0; i < packers.size(); ++i)
            {
                json << "\t\t{" << endl;
                packers[i]->SaveJson(name + to_string(i), json,options & CrunchOptions::optTrim,options & CrunchOptions::optRotate);
                json << "\t\t}";
                if (i + 1 < packers.size())
                    json << ',';
                json << endl;
            }
            json << "\t]" << endl;
            json << '}';
        }
        
        //Save the new hash
        SaveHash(newHash, outputDir + name + ".hash");


        return true;

    }

}