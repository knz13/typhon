#pragma once
#include "../general.h"
#include "../generic_reflection.h"
#include "../object.h"
#include "../engine.h"
#include <unordered_map>

class PrefabInternals;

DEFINE_HAS_SIGNATURE(has_create_prefab,T::CreatePrefab,Object (*)());
DEFINE_HAS_SIGNATURE(has_create_prefab_non_static,T::CreatePrefab,Object (T::*)());

template<typename T>
class Prefab : public Reflection::IsInitializedStatically<Prefab<T>> {
public:
    virtual std::string GetPrefabName() {
        return HelperFunctions::GetClassNameString<T>();
    }

    virtual std::string GetPrefabPath() {
        return "";
    }

    virtual Object CreatePrefab() {
        return Engine::CreateObject("");
    };

    static void InitializeStatically();
};

class PrefabInternals {
public:

    static std::string GetPrefabsJSON();


    static std::unordered_map<std::string,int64_t> prefabsInstantiationMap;
    static std::unordered_map<int64_t,std::function<Object()>> prefabsIDToFunction;
};

template<typename T>
void Prefab<T>::InitializeStatically() {
    std::cout << "Initializing statically for prefab!" << std::endl;
    if constexpr (has_create_prefab<T>::value) {
        std::string prefabPath = T().GetPrefabPath() + "/" + T().GetPrefabName();
        int64_t hash = HelperFunctions::HashString(prefabPath);
        PrefabInternals::prefabsInstantiationMap[prefabPath] = hash;
        PrefabInternals::prefabsIDToFunction[hash] = [](){
            return T::CreatePrefab();
        };
    }
    if constexpr (has_create_prefab_non_static<T>::value) {
        std::string prefabPath = T().GetPrefabPath() + "/" + T().GetPrefabName();
        int64_t hash = HelperFunctions::HashString(prefabPath);
        PrefabInternals::prefabsInstantiationMap[prefabPath] = hash;
        PrefabInternals::prefabsIDToFunction[hash] = [](){
            return T().CreatePrefab();
        };
    }
}