#pragma once
#include "../prefab.h"


class Cube : public Prefab<Cube> {
public:
    
    std::string GetPrefabPath() override {
        return "Solids/3D/Cube";
    }

    Object CreatePrefab() override {
        return Engine::CreateObject("Cube");
    };
};