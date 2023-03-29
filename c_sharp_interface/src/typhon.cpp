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
// -- INCLUDE CREATED CLASSES -- //

bool initializeCppLibrary() {
    
    MonoManager::getInstance();
    ShaderCompiler::getInstance();
    Engine::Initialize();

    Reflection::IsInitializedStatically<Reflection::NullClassHelper>::InitializeDerivedClasses();

    return true;    

}

void attachCreateGameObjectFunction(CreateGameObjectFunc func)
{   
    std::cout << "attaching create game object func!" <<std::endl;
    GameObjectMiddleMan::createGameObjectAndGetID = [=](){
        return func();
    };

    
    Player<>();
    NPC<>();
    // -- INITIALIZE EACH OBJECT -- //    

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
        std::cout << "Trying to get hierarchy menu options" << std::endl;
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

void onMouseMove(double positionX, double positionY)
{
    //std::cout << "Receiving mouse move event!" << positionX << " , " << positionY << std::endl;
    Engine::mousePosition = Vector2f(positionX,positionY);
}

void onKeyboardKeyDown(InputKey input)
{
    //std::cout << "receiving keyboard event! id = " << input << " registered number " << GameObjectMiddleMan::objectsToCallKeysCallback.size() << std::endl;
    for(auto& [id,obj] : GameObjectMiddleMan::objectsToCallKeysCallback){
        GameObjectMiddleMan::classesThatHaveHasKeyCallbacks[obj->GetClassName()](obj,input);
    }
}

void attachPointersToObject(AttachPointersToObjectFunc func)
{
    GameObjectMiddleMan::attachPointersToObject = [=](int64_t id){
        std::cout << "Calling attach pointers to object with id " << id << std::endl;
        func(id);
    };
}


void attachScalePointerToGameObject(int64_t id, double *scalePointerX, double *scalePointerY)
{   
    std::cout << "trying to attach scale pointers to object " << id << std::endl;
    if(GameObjectMiddleMan::aliveObjects.find(id) != GameObjectMiddleMan::aliveObjects.end()){
        GameObjectMiddleMan::aliveObjects[id].get()->_scalePointerX = scalePointerX;
        GameObjectMiddleMan::aliveObjects[id].get()->_scalePointerY = scalePointerY;
    }
}

void attachPositionPointersToGameObject(int64_t id, double *positionX, double *positionY)
{
    std::cout << "trying to attach position pointers to object " << id << std::endl;
    if(GameObjectMiddleMan::aliveObjects.find(id) != GameObjectMiddleMan::aliveObjects.end()){    
        GameObjectMiddleMan::aliveObjects[id].get()->_positionX = positionX;
        GameObjectMiddleMan::aliveObjects[id].get()->_positionY = positionY;
    }
}

void attachAddTextureToObjectFunction(LoadTextureToObject func)
{   
    GameObjectMiddleMan::loadTextureToObjectFunc = [=](int64_t id,const char* texturePath){
        func(id,texturePath);
    };

}

void removeObjectFromObjectsBeingDeleted(int64_t id)
{
    if(GameObjectMiddleMan::objectsBeingDeleted.find(id) != GameObjectMiddleMan::objectsBeingDeleted.end()){
        GameObjectMiddleMan::objectsBeingDeleted.erase(id);
    }
    else {
        std::cout << "Tried to delete object with id " << id <<  " from the list of objects being deleted!" << std::endl;
    }
}
