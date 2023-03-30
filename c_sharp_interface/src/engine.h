#pragma once
#include "general.h"
#include "generic_reflection.h"

class Engine {
public:
    static void Initialize();

    
private:
    static Vector2f mousePosition;
    static entt::registry registry;

};
