#include <iostream>
#include <stdint.h>
#include "typhon.h"
#include "mono_manager.h"
#include "shader_compiler.h"
#include "gameobject.h"
#include "npc.h"
#include "reflection.h"
#include "player.h"
#include "engine.h"

bool initializeCppLibrary() {
    
    MonoManager::getInstance();
    ShaderCompiler::getInstance();
    Engine::Initialize();
    

    return true;    

}

void attachCreateGameObjectFunction(CreateGameObjectFunc func)
{   
    std::cout << "attaching create game object func!" <<std::endl;
    GameObjectMiddleMan::createGameObjectAndGetID = [=](){
        return func();
    };

    //Initialize one of each object (for compiler reasons...)
    Player();
    NPC();

    for(const auto& func : GameObjectMiddleMan::staticDefaultsFuncs){
        func();
    }

}

void attachRemoveGameObjectFunction(RemoveGameObjectFunc func)
{
    GameObjectMiddleMan::removeGameObjectFromID = [=](int64_t id){
        func(id);
    };
}


RemoveObjectFunc attachOnRemoveObjectFunction()
{
    return &GameObjectMiddleMan::onCallToRemoveObject;
}

ClassesArray getClassesToAddToHierarchyMenu() {
    static std::vector<int64_t> vec;
    static std::vector<const char*> charVec;

    if(vec.size() == 0){
        std::cout << "Trying to get hierarchy menu stuff" << std::endl;
        std::cout << "Current hierarchy pool size: " << GameObjectMiddleMan::menuOptionsStringToOnClick.size() << " and id to string: " << GameObjectMiddleMan::menuOptionsIDtoString.size() << std::endl;
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
    if(GameObjectMiddleMan::menuOptionsIDtoString.find(id) != GameObjectMiddleMan::menuOptionsIDtoString.end()){
        std::cout << "Creating object from class id " << id << std::endl;
        GameObjectMiddleMan::menuOptionsStringToOnClick[GameObjectMiddleMan::menuOptionsIDtoString[id]]();
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
    if(GameObjectMiddleMan::aliveObjects.find(id) != GameObjectMiddleMan::aliveObjects.end()){
        GameObjectMiddleMan::aliveObjects[id].get()->_scalePointerX = scalePointerX;
        GameObjectMiddleMan::aliveObjects[id].get()->_scalePointerY = scalePointerY;
    }
}

void attachPositionPointersToGameObject(int id, double *positionX, double *positionY)
{
    if(GameObjectMiddleMan::aliveObjects.find(id) != GameObjectMiddleMan::aliveObjects.end()){    
        GameObjectMiddleMan::aliveObjects[id].get()->_positionX = positionX;
        GameObjectMiddleMan::aliveObjects[id].get()->_positionY = positionY;
    }
}
