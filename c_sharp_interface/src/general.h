#pragma once
#include "entt/entt.hpp"

template<typename T>
using deleted_unique_ptr = std::unique_ptr<T,std::function<void(T*)>>;


typedef int64_t (*CreateGameObjectFunc)();
typedef void (*FindFrameFunc)(int64_t);
typedef void (*SetDefaultsFunc)(int64_t);
typedef void (*AIFunc)(int64_t);
typedef void (*UpdateFunc)(int64_t,double);
typedef void (*PreDrawFunc)(int64_t);
typedef void (*PostDrawFunc)(int64_t);
typedef const char* (*AddToEntityMenuFunc)(void);


namespace HelperFunctions {

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
};