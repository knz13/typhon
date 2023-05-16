#pragma once
#include "general.h"
#include "shader_compiler.h"
#include <chrono>



struct RenderPassData {
public:    
    std::string vertexShaderName = "";
    std::string fragmentShaderName = "";
    std::vector<std::string> textureNames = {};

};

class PlatformSpecificRenderingEngine {
public:
    //General
    virtual void ReceivePlatformSpecificViewPointer(void* view) {};
    virtual void* GetPlatformSpecificPointer() {return nullptr;};
    virtual void InitializeRenderingEngine() {};
    virtual void UnloadRenderingEngine() {};
    
    //Shaders
    virtual bool LoadFragmentShader(std::string shaderName,ShaderCompilationResult& shaderSource) {return false;}
    virtual bool LoadVertexShader(std::string shaderName,ShaderCompilationResult& shaderSource) {return false;}
    virtual bool UnloadVertexShader(std::string shaderName) {return false;}
    virtual bool UnloadFragmentShader(std::string shaderName) {return false;}
    
    //Textures
    virtual void CreateTextureFromName(std::string name,int width,int height,std::vector<char> bufferData) {};
    virtual bool UnloadTextureFromName(std::string name) {return false;};
    
    //Rendering
    virtual RenderPassData& EnqueueRenderLoadedTextureRect() {
        static RenderPassData temp;
        return temp;
    }

    void SetUpdateFunction(std::function<void(double)> func) {
        updateFunc = func;
    }

protected:
    void CallUpdateFunc() {
        std::chrono::time_point<std::chrono::system_clock> newTime = std::chrono::system_clock::now();

        auto difference = std::chrono::duration_cast<std::chrono::milliseconds>(newTime - lastUpdateTime);

        updateFunc(difference.count());
    }

private:
    std::function<void(double)> updateFunc = [](double) {};
    std::chrono::time_point<std::chrono::system_clock> lastUpdateTime = std::chrono::system_clock::now();

};




class RenderingEngine {
public:
    


    static void InitializeEngine();

    static void SetUpdateFunction(std::function<void(double)> func) {
       if(platformSpecificRenderingEngine){
        platformSpecificRenderingEngine->SetUpdateFunction(func);
       }
    };

    static void UnloadEngine() {
        if(platformSpecificRenderingEngine){
            platformSpecificRenderingEngine.get()->UnloadRenderingEngine();
        }
    };

    static void* GetPlatformSpecificPointer();

    static void PassPlatformSpecificViewPointer(void* view);

private:
    static std::unique_ptr<PlatformSpecificRenderingEngine> platformSpecificRenderingEngine;
    


};