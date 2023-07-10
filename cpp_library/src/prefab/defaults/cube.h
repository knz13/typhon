#pragma once
#include "../prefab.h"


class Cube : public Prefab<Cube> {
public:
    std::string GetPrefabName() override {
        return "Cube";
    }

    std::string GetPrefabPath() override {
        return "Solids/3d";
    }

    Object CreatePrefab() override {
        return Engine::CreateObject("Cube");
    };
};