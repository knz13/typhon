#pragma once
#ifndef TYPHON_ON_EDITOR
#define TYPHON_NOT_ON_EDITOR 1
#endif
#define _USE_MATH_DEFINES
#include <cmath>
#include <iostream>
#include "vendor/entt/single_include/entt/entt.hpp"
#include "vendor/random/include/effolkronium/random.hpp"
#include "vendor/glm/glm/glm.hpp"
#include "vendor/yael/include/yael.h"
#include "vendor/json/single_include/nlohmann/json.hpp"
#include "vendor/dylib/include/dylib.hpp"
#include <bitset>
#include <functional>

#ifdef __APPLE__
#include "vendor/metal-cpp/metal-cpp-extensions/AppKit/AppKit.hpp"
#include "vendor/metal-cpp/metal-cpp/Foundation/Foundation.hpp"
#include "vendor/metal-cpp/metal-cpp/Metal/Metal.hpp"
#include "vendor/metal-cpp/metal-cpp-extensions/MetalKit/MetalKit.hpp"
#include "vendor/metal-cpp/metal-cpp/QuartzCore/QuartzCore.hpp"
#endif


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

#if defined(__clang__) || defined(__GNUC__)
#define FUNCTION_SIGNATURE __PRETTY_FUNCTION__
#elif defined(_MSC_VER)
#define FUNCTION_SIGNATURE __FUNCSIG__
#else
#error "Unsupported compiler"
#endif


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

    template<typename T>    
    struct ClassName {
        static constexpr const char* get() {
            return FUNCTION_SIGNATURE;
        }
    };

    template<typename T>
    struct ClassNameStorage {
        static constexpr std::size_t maxLength = 256;
        static inline char className[maxLength] = {};
    };

    template<typename... Others>
    constexpr int IndexOfTopClass() {
        return IndexOfTopClassInternal<Others...>(0);
    } 

}
namespace HelperFunctions {

    template<typename Container>
    static Container MapContainer(Container & container,typename Container::value_type(*f)(typename Container::value_type&)) {
        Container output;
        std::transform(container.begin(), container.end(), std::back_inserter(output), f);
        return output;
    }

    template<typename Container>
    static Container MapContainer(Container & container,typename Container::value_type(*f)(typename Container::value_type)) {
        Container output;
        std::transform(container.begin(), container.end(), std::back_inserter(output), f);
        return output;
    }

    template<typename Container>
    static void ForEach(Container& container,void(*f)(typename Container::value_type&)){
        std::for_each(container.begin(),container.end(),f);
    }
    template<typename Container>
    static void ForEach(Container& container,void(*f)(typename Container::value_type)){
        std::for_each(container.begin(),container.end(),f);
    }

    static double Radians(double degrees) {
        return (M_PI/180)*degrees;
    }

    constexpr std::size_t StringLength(const char* str) {
        std::size_t len = 0;
        while (str[len] != '\0') {
            ++len;
        }
        return len;
    }

    constexpr bool StartsWith(const char* str, std::string_view target) {
        std::size_t targetLen = target.size();
        for (std::size_t i = 0; i < targetLen; ++i) {
            if (str[i] != target[i]) {
                return false;
            }
        }
        return true;
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
    
    namespace {

        constexpr std::size_t classNameStart(std::string_view name) {
        #if defined(_MSC_VER)
            return name.find_first_of('<') + 1;
        #else
            return name.find_first_of('=') + 2;
        #endif
        }

        constexpr std::size_t classNameEnd(std::string_view name) {
        #if defined(_MSC_VER)
            return name.find_first_of('>', classNameStart(name));
        #else
            return name.find_first_of(']', classNameStart(name));
        #endif
        }
    }

    template<typename T>
    constexpr const char* GetClassNameStringCompileTime() {
        constexpr auto typeInfo = std::string_view{Reflection::ClassName<T>::get()};
        constexpr auto start = classNameStart(typeInfo);
        constexpr auto end = classNameEnd(typeInfo);
        constexpr auto classNameLength = end - start;

        static_assert(classNameLength > 0, "Class name must not be empty.");
        static_assert(classNameLength < Reflection::ClassNameStorage<T>::maxLength, "Class name is too long.");

        for (std::size_t i = 0; i < classNameLength; ++i) {
            Reflection::ClassNameStorage<T>::className[i] = typeInfo[start + i];
        }
        Reflection::ClassNameStorage<T>::className[classNameLength] = '\0';

        return Reflection::ClassNameStorage<T>::className;
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

    static int64_t HashString(std::string str) {
        return entt::hashed_string(str.c_str());
    }

    template<typename T>
    static int64_t GetClassID() {
        return entt::hashed_string(GetClassNameString<T>().c_str()).operator entt::id_type();
    };

    static std::vector<std::string> SplitString(const std::string& s, const std::string& delimiter) {
        std::vector<std::string> result;
        size_t pos_start = 0, pos_end, delim_len = delimiter.length();
        std::string token;

        while ((pos_end = s.find(delimiter, pos_start)) != std::string::npos) {
            token = s.substr(pos_start, pos_end - pos_start);
            pos_start = pos_end + delim_len;
            result.push_back(token);
        }

        result.push_back(s.substr(pos_start));
        return result;
    }


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
