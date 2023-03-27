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
    std::cout << "attaching create game object func!" <<std::endl;
    GameObject::addGameObject = [=](){
        int id = func();
        if(GameObject::aliveObjects.find(id) == GameObject::aliveObjects.end()){
            GameObject::aliveObjects[id] = GameObject();
        }
        else{
            std::cout << "Tried to create gameobject with id " << id << " but some other with this id already exists!!" << std::endl;
        }
        return GameObject::aliveObjects[id];
    };

    GameObject::addGameObject();
}

FindFrameFunc attachFindFrameFunction()
{
    return &GameObjectMiddleMan::onCallFindFrame;
}

AIFunc attachAIFunction()
{
    return &GameObjectMiddleMan::onCallAI;
}

SetDefaultsFunc attachSetDefaultsFunction()
{
    return &GameObjectMiddleMan::onCallSetDefaults;
}

UpdateFunc attachUpdateFunction()
{
    return &GameObjectMiddleMan::onCallUpdate;
}

PreDrawFunc attachPreDrawFunction()
{
    return &GameObjectMiddleMan::onCallPreDraw;
}

PostDrawFunc attachPostDrawFunction()
{
    return &GameObjectMiddleMan::onCallPostDraw;
}

void attachScalePointerToGameObject(int id, double * scalePointerX,double* scalePointerY)
{   
    if(GameObject::aliveObjects.find(id) != GameObject::aliveObjects.end()){
        GameObject::aliveObjects[id]._scalePointerX = scalePointerX;
        GameObject::aliveObjects[id]._scalePointerY = scalePointerY;
    }
}

void attachPositionPointersToGameObject(int id, double *positionX, double *positionY)
{
    if(GameObject::aliveObjects.find(id) != GameObject::aliveObjects.end()){    
        GameObject::aliveObjects[id]._positionX = positionX;
        GameObject::aliveObjects[id]._positionY = positionY;
    }
}
