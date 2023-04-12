#pragma once
#include "general.h"



class ECSRegistry {
    
    static entt::registry registry;

public:
    static entt::registry& Get() {
        return registry;
    }

};