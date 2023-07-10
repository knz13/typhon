#include "prefab.h"
#include "filesystem"

std::unordered_map<std::string,int64_t> PrefabInternals::prefabsInstantiationMap;
std::unordered_map<int64_t,std::function<Object()>> PrefabInternals::prefabsIDToFunction;

std::string PrefabInternals::GetPrefabsJSON() {
    json prefabs;
    std::cout << "Getting prefabs!" << std::endl;
    for(const auto& [path,hash] : prefabsInstantiationMap){
        auto strVector = HelperFunctions::SplitString(path,"/");
        std::string prefabName = strVector.back();
        json* jsonPtr = &prefabs;
        for(auto& str : strVector){
            if(str == prefabName){
                break;
            }
            if ((*jsonPtr).find(str) == (*jsonPtr).end()) {
                (*jsonPtr)[str] = json::object();
            }
            jsonPtr = &(*jsonPtr)[str];
        }
        (*jsonPtr)[prefabName] = hash;
    }
    std::cout << "Got prefabs!" << std::endl;

    return prefabs.dump();
}