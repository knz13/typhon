#include <iostream>
#include <stdint.h>
#include "typhon.h"
#include "sol/sol.hpp"
#include "lua.h"






int load_script_from_string(char* string,int stringLen) {

};



void registerCreateComponentFunction(CreateComponentFunction func) {
    Lua::createComponentFunction = [=](int a){
        return func(a);
    };
    
    func(-1);
}

