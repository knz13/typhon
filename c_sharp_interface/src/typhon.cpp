#include <iostream>
#include <stdint.h>
#include "typhon.h"
#include "mono_manager.h"
#include "shader_compiler.h"
#include "gameobject.h"


bool initializeCppLibrary() {
    
    MonoManager::getInstance();
    ShaderCompiler::getInstance();

    return true;

}

void attachCreateGameObjectFunction(CreateGameObjectFunc func)
{
    GameObject::addGameObject = [=](std::string value){
        return GameObject(func(value.c_str()));
    };
}
