#pragma once
#include "../prefab.h"


class EmptyObject : public Prefab<EmptyObject> {
public:
    

    std::string GetPrefabPath() override {
        return "Empty Object";
    }

    Object CreatePrefab() override {
        return Engine::CreateObject("Empty Object");
    };
};