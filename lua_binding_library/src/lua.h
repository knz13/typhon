#pragma once
#include "sol/sol.hpp"
#include <iostream>
#include <functional>

class Lua {
public:
    static sol::state state;
    inline static std::function<int(int)> createComponentFunction = [](int a){return 0;};


};