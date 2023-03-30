#include <iostream>
#include <stdint.h>
#include "typhon.h"
#include "mono_manager.h"
#include "shader_compiler.h"
#include "engine.h"
// -- INCLUDE CREATED CLASSES -- //

bool initializeCppLibrary() {
    
    MonoManager::getInstance();
    ShaderCompiler::getInstance();
    Engine::Initialize();


    return true;    

}


void onMouseMove(double positionX, double positionY)
{
   
}

void onKeyboardKeyDown(InputKey input)
{
    
}
