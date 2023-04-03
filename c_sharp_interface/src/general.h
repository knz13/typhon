#pragma once
#include "../vendor/entt/src/entt/entt.hpp"
#include "../vendor/random/include/effolkronium/random.hpp"
#include "../vendor/glm/glm/glm.hpp"
#include "../vendor/yael/include/yael.h"
#include "../vendor/json/single_include/nlohmann/json.hpp"

using json = nlohmann::json;
using Random = effolkronium::random_static;


using Vector2f = glm::vec2;
using Vector3f = glm::vec3;

template<typename T>
using deleted_unique_ptr = std::unique_ptr<T,std::function<void(T*)>>;


typedef int64_t (*CreateGameObjectFunc)();
typedef void (*RemoveGameObjectFunc)(int64_t);
typedef void (*FindFrameFunc)(int64_t);
typedef void (*AttachPointersToObjectFunc)(int64_t);
typedef void (*SetDefaultsFunc)(int64_t);
typedef void (*AIFunc)(int64_t);
typedef void (*UpdateFunc)(int64_t,double);
typedef void (*PreDrawFunc)(int64_t);
typedef void (*PostDrawFunc)(int64_t);
typedef void (*EnqueueObjectRender)(double,double,int64_t,int64_t,int64_t,int64_t);
typedef void (*RemoveObjectFunc)(int64_t);
typedef void (*LoadTextureToObject)(int64_t,const char*);
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

    template<typename T>
    static int64_t GetIDFromString() {
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

