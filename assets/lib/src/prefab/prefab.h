#pragma once
#include "../general.h"
#include "../generic_reflection.h"
#include "../object/object.h"
#include "../engine.h"
#include <unordered_map>

class PrefabInternals;

DEFINE_HAS_SIGNATURE(has_create_prefab,T::CreatePrefab,Typhon::Object (*)());
DEFINE_HAS_SIGNATURE(has_create_prefab_non_static,T::CreatePrefab,Typhon::Object (T::*)());

template<typename T>
class Prefab : public Reflection::IsInitializedStatically<Prefab<T>> {
public:
    

    virtual std::string GetPrefabPath() {
        return HelperFunctions::GetClassNameString<T>();
    }

    virtual Typhon::Object CreatePrefab() {
        return Engine::CreateObject("");
    };

    static void InitializeStatically();
};

class PrefabInternals {
public:

    static std::string GetPrefabsJSON();
    static Typhon::Object CreatePrefabFromID(int64_t id) {
        if(prefabsIDToFunction.find(id) != prefabsIDToFunction.end()){
            return prefabsIDToFunction[id]();
        }
        std::cout << "Trying to create a prefab from an unknown prefab ID!" << std::endl;
        return Typhon::Object();
    }


    static std::unordered_map<std::string,int64_t> prefabsInstantiationMap;
    static std::unordered_map<int64_t,std::function<Typhon::Object()>> prefabsIDToFunction;
};

template<typename T>
void Prefab<T>::InitializeStatically() {
    std::string prefabPath = T().GetPrefabPath();
    if constexpr (has_create_prefab<T>::value) {
        int64_t hash = HelperFunctions::HashString(prefabPath);
        PrefabInternals::prefabsInstantiationMap[prefabPath] = hash;
        PrefabInternals::prefabsIDToFunction[hash] = [](){
            return T::CreatePrefab();
        };
    }
    if constexpr (has_create_prefab_non_static<T>::value) {
        
        int64_t hash = HelperFunctions::HashString(prefabPath);
        PrefabInternals::prefabsInstantiationMap[prefabPath] = hash;
        PrefabInternals::prefabsIDToFunction[hash] = [](){
            return T().CreatePrefab();
        };
    }
}