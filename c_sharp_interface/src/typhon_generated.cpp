/*
GENERATED FILE - DO NOT MODIFY!
*/
#include <iostream>
#include <stdint.h>
#include "typhon.h"
#include "mono_manager.h"
#include "shader_compiler.h"
#include "engine.h"
#include "TerrariaLikeGame/FlyingTreant.h"

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

void onUpdateCall(double dt)
{
    Engine::Update(dt);


}
