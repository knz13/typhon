#pragma once
#define SOL_ALL_SAFETIES_ON 1
#include "sol/sol.hpp"
#include <iostream>
#include <functional>
#include <map>

class Lua {
public:
    static sol::state state;
    inline static std::function<int(int)> addGameObjectFunction = [](int a){return 0;};
    inline static std::function<int(int)> removeGameObjectFunction = [](int a){return 0;};
    
    
};