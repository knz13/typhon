#pragma once
#include <iostream>
#include <functional>
#include "general.h"



class GameObject {
public:
    inline static std::function<GameObject(std::string name)> addGameObject;
    

    GameObject(int identifier);

private:
    int identifier;

};