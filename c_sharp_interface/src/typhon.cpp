#include <iostream>
#include <stdint.h>
#include "typhon.h"
#include "mono_manager.h"
#include "shader_compiler.h"
#include "gameobject.h"
#include "npc.h"
#include "reflection.h"
#include "player.h"

bool initializeCppLibrary() {
    
    MonoManager::getInstance();
    ShaderCompiler::getInstance();

   

    return true;    

}

void attachCreateGameObjectFunction(CreateGameObjectFunc func)
{   
    std::cout << "attaching create game object func!" <<std::endl;
    GameObject::createGameObjectAndGetID = [=](){
        return func();
    };

    //Initialize one of each object (for compiler reasons...)
    Player();
    NPC();

    for(const auto& func : GameObjectMiddleMan::staticDefaultsFuncs){
        func();
    }

}

ClassesArray getClassesToAddToHierarchyMenu() {
    static std::vector<int64_t> vec;
    static std::vector<const char*> charVec;

    if(vec.size() == 0){
        for(const auto& [id,str] : GameObjectMiddleMan::menuOptionsIDtoString){
            vec.push_back(id);
            charVec.push_back(str.c_str());
        }
    }

    

    ClassesArray arr;
    arr.array = vec.data();
    arr.size = vec.size();
    arr.stringArray = charVec.data();
    arr.stringArraySize = charVec.size();

    return arr;
}

void addGameObjectFromClassID(int64_t id)
{
    if(GameObject::menuOptionsIDtoString.find(id) != GameObject::menuOptionsIDtoString.end()){
        std::cout << "Creating object from id " << id << std::endl;
        GameObject::menuOptionsStringToOnClick[GameObject::menuOptionsIDtoString[id]]();
    }
    else{
        std::cout << "Could not create object from id " << id << std::endl;
    }
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
        GameObject::aliveObjects[id].get()->_scalePointerX = scalePointerX;
        GameObject::aliveObjects[id].get()->_scalePointerY = scalePointerY;
    }
}

void attachPositionPointersToGameObject(int id, double *positionX, double *positionY)
{
    if(GameObject::aliveObjects.find(id) != GameObject::aliveObjects.end()){    
        GameObject::aliveObjects[id].get()->_positionX = positionX;
        GameObject::aliveObjects[id].get()->_positionY = positionY;
    }
}
