#pragma once
#define _USE_MATH_DEFINES
#include <cmath>
#include <iostream>
#include "vendor/ecspp/include/ecspp.h"
#include "vendor/random/include/effolkronium/random.hpp"
#include "vendor/glm/glm/glm.hpp"
#include "vendor/yael/include/yael.h"
#include "vendor/json/single_include/nlohmann/json.hpp"
#include <bitset>
#include <functional>

#ifndef M_PI
#define M_PI 3.141592653589793238462643383279502884197
#endif

using json = nlohmann::json;
using Random = effolkronium::random_static;


using Vector2f = glm::vec2;
using Vector3f = glm::vec3;

template<typename T>
using deleted_unique_ptr = std::unique_ptr<T,std::function<void(T*)>>;

struct Anchor {
    static Anchor TopLeft;
    static Anchor Top;
    static Anchor TopRight;
    static Anchor CenterLeft;
    static Anchor Center;
    static Anchor CenterRight;
    static Anchor BottomLeft;
    static Anchor Bottom;
    static Anchor BottomRight;


    double x = 0;
    double y = 0;

    Anchor() {};
    Anchor(std::string type) {
        this->type = type;
    };
    Anchor(double x,double y) : x(x),y(y) {};

private:
    std::string type = "None";

    friend class Engine;

};

typedef int64_t (*CreateGameObjectFunc)();
typedef void (*RemoveGameObjectFunc)(int64_t);
typedef void (*FindFrameFunc)(int64_t);
typedef void (*AttachPointersToObjectFunc)(int64_t);
typedef void (*SetDefaultsFunc)(int64_t);
typedef void (*AIFunc)(int64_t);
typedef void (*UpdateFunc)(int64_t,double);
typedef void (*PreDrawFunc)(int64_t);
typedef void (*PostDrawFunc)(int64_t);
typedef void (*EnqueueObjectRender)(double,double,int64_t,int64_t,int64_t,int64_t,double,double,double,double);
typedef void (*OnChildrenChangedFunc)();
typedef void (*RemoveObjectFunc)(int64_t);
typedef void (*LoadTextureToObject)(int64_t,const char*);
typedef const char* (*AddToEntityMenuFunc)(void);

namespace {

    template<typename T,typename... Others>
    constexpr bool DerivedFromAllOthers() {
        return (std::is_base_of<Others,T>::value && ...);
    }

    template<typename T,typename... Others>
    constexpr int IndexOfTopClassInternal(const int i) {
        if (i > sizeof...(Others)){
            return -1;
        }
        if constexpr (DerivedFromAllOthers<T,Others...>()) {
            return i;
        }
        return IndexOfTopClassInternal<Others...,T>(i+1);
    }
}

namespace Reflection {


    template<typename... Others>
    constexpr int IndexOfTopClass() {
        return IndexOfTopClassInternal<Others...>(0);
    } 

}
namespace HelperFunctions {

    static double Radians(double degrees) {
        return (M_PI/180)*degrees;
    }

    static bool EraseWordFromString(std::string& mainWord, std::string wordToLookFor) {
        auto iter = mainWord.find(wordToLookFor);
        
        bool foundAny = false;
        if(iter != std::string::npos){
            foundAny = true;
        }
        while (iter != std::string::npos) {
            
            mainWord.erase(iter, wordToLookFor.length());
            
            iter = mainWord.find(wordToLookFor, iter);
        }
    
        return foundAny;
    }


    static void ReplaceAll( std::string &s, const std::string &search, const std::string &replace) {
        for( size_t pos = 0; ; pos += replace.length() ) {
            // Locate the substring to replace
            pos = s.find( search, pos );
            if( pos == std::string::npos ) break;
            // Replace by erasing and inserting
            s.erase( pos, search.length() );
            s.insert( pos, replace );
        }
    }

    template<typename T>
    static std::string GetClassNameString() {
        std::string name = std::string(entt::type_id<T>().name());
        HelperFunctions::EraseWordFromString(name, "class ");
        HelperFunctions::EraseWordFromString(name, "struct ");
        if (auto loc = name.find_last_of(':'); loc != std::string::npos) {
            name = std::string(name.begin() + loc + 1, name.end());
        }
        return name;
    }

    template<typename T>
    static int64_t GetClassID() {
        static std::hash<std::string> hasher;
            

        return static_cast<int64_t>(hasher(GetClassNameString<T>()));


    };


};

class HelperStatics {
public:
    static std::string projectPath;

};



template<int N, typename... Ts> using NthTypeOf =
        typename std::tuple_element<N, std::tuple<Ts...>>::type;


struct ClassesArray {
    int64_t* array;
    const char** stringArray;
    int64_t stringArraySize;
    int64_t size;
};

struct AliveObjectsArray {
    int64_t* array;
    int64_t size;
};
