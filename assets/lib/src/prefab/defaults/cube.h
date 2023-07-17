#pragma once
#include "../prefab.h"
#include "../../component/default_components/transform.h"

class Cube : public Prefab<Cube> {
public:
    
    std::string GetPrefabPath() override {
        return "Solids/3D/Cube";
    }

    Typhon::Object CreatePrefab() override {
        Typhon::Object obj = Engine::CreateObject("Cube");
        return obj;
    };
};