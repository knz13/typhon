#pragma once
#include "../prefab.h"
#include "../../component/default_components/transform.h"

class Cube : public Prefab<Cube> {
public:
    
    std::string GetPrefabPath() override {
        return "Solids/3D/Cube";
    }

    Object CreatePrefab() override {
        Object obj = Engine::CreateObject("Cube");
        obj.AddComponent<Transform>();
        return obj;
    };
};