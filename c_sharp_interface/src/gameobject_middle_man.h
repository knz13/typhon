#pragma once
#include <iostream>
#include <functional>
#include "general.h"
#include <unordered_map>
#include <map>
#include <vector>

struct HierarchyMenuObject {
    std::function<void()> onClick;
};

class GameObjectMiddleMan {
public:
    inline static std::function<int64_t()> createGameObjectAndGetID;
    inline static std::function<void(int64_t)> removeGameObjectFromID;
    inline static std::function<void(int64_t)> attachPointersToObject;
    inline static std::unordered_map<uint64_t,std::string> menuOptionsIDtoString;
    inline static std::unordered_map<int64_t,GameObjectMiddleMan*> objectsToCallKeysCallback;
    inline static std::map<std::string,std::function<void(GameObjectMiddleMan*,InputKey)>> classesThatHaveHasKeyCallbacks;
    inline static std::unordered_map<std::string,std::function<void()>> menuOptionsStringToOnClick;
    inline static std::vector<std::function<void()>> staticDefaultsFuncs;
    inline static std::unordered_map<int64_t,std::unique_ptr<GameObjectMiddleMan>> aliveObjects;


    template<typename T>
    static T& CreateNewGameObject() {
        int64_t id = GameObjectMiddleMan::createGameObjectAndGetID();
        std::cout << "Creating object with id " << id << " and type " << HelperFunctions::GetClassNameString<T>() <<  std::endl;
        
        if(GameObjectMiddleMan::aliveObjects.find(id) == GameObjectMiddleMan::aliveObjects.end()){
            GameObjectMiddleMan::aliveObjects[id] = std::unique_ptr<GameObjectMiddleMan>(static_cast<GameObjectMiddleMan*>(new T()));
            GameObjectMiddleMan::aliveObjects[id].get()->identifier = id;
            GameObjectMiddleMan::aliveObjects[id].get()->className = HelperFunctions::GetClassNameString<T>();

            
            std::cout << "Created player! Checking if keys callback registered!" << std::endl;
            GameObjectMiddleMan::attachPointersToObject(id);

            if(GameObjectMiddleMan::classesThatHaveHasKeyCallbacks.find(HelperFunctions::GetClassNameString<T>())
                != GameObjectMiddleMan::classesThatHaveHasKeyCallbacks.end()){
                std::cout << "Registering keys callback!" << std::endl;
                GameObjectMiddleMan::objectsToCallKeysCallback[id] = GameObjectMiddleMan::aliveObjects[id].get();
            }
        }
        else{
            std::cout << "Tried to create GameObjectMiddleMan with id " << id << " but some other with this id already exists!!" << std::endl;
        }
        return (T&)(*GameObjectMiddleMan::aliveObjects[id].get());
    }

    static void RemoveGameObject(GameObjectMiddleMan other){
        int64_t id = other.identifier;  
        if(GameObjectMiddleMan::aliveObjects.find(id) != GameObjectMiddleMan::aliveObjects.end()){
            std::cout << "removing object with id = " << id << std::endl;
            if(GameObjectMiddleMan::objectsToCallKeysCallback.find(id) != GameObjectMiddleMan::objectsToCallKeysCallback.end()){
                GameObjectMiddleMan::objectsToCallKeysCallback.erase(id);
            }
            GameObjectMiddleMan::aliveObjects[id].get()->GameObjectOnRemove();
            GameObjectMiddleMan::aliveObjects.erase(id);
        }
    }

    static void RemoveGameObjectByID(int64_t id){
        if(GameObjectMiddleMan::aliveObjects.find(id) != GameObjectMiddleMan::aliveObjects.end()){
            std::cout << "removing object with id = " << id << std::endl;
            if(GameObjectMiddleMan::objectsToCallKeysCallback.find(id) != GameObjectMiddleMan::objectsToCallKeysCallback.end()){
                GameObjectMiddleMan::objectsToCallKeysCallback.erase(id);
            }
            GameObjectMiddleMan::aliveObjects[id].get()->GameObjectOnRemove();
            GameObjectMiddleMan::aliveObjects.erase(id);
        }
        else{
            std::cout << "Trying to delete an object with an invalid id!" << std::endl;
            std::cout << "id = " << id << std::endl;
        }
    }

    static void onCallUpdate(int64_t id,double dt) {
        //std::cout << "calling update!" << std::endl;
        *aliveObjects[id].get()->_positionX  = aliveObjects[id].get()->position.x;
        *aliveObjects[id].get()->_positionY  = aliveObjects[id].get()->position.y;
        *aliveObjects[id].get()->_scalePointerX = aliveObjects[id].get()->scale.x;
        *aliveObjects[id].get()->_scalePointerY = aliveObjects[id].get()->scale.y;
        
        aliveObjects[id].get()->GameObjectUpdate(dt);
    }

    static void onCallSetDefaults(int64_t id){
        aliveObjects[id].get()->GameObjectSetDefaults();
    }

    static void onCallPreDraw(int64_t id) {
        aliveObjects[id].get()->GameObjectPreDraw();
    }

    static void onCallPostDraw(int64_t id){
        aliveObjects[id].get()->GameObjectPostDraw();
    }

    static void onCallToRemoveObject(int64_t id);

    int64_t identifier;
    double* _positionX;
    double* _positionY;
    double* _scalePointerX;
    double* _scalePointerY;
    
    std::string className = "";
    std::string GetClassName() {
        return className;
    }
    
    virtual void GameObjectOnRemove() {};
protected:
    Vector2f position = Vector2f(0,0);
    Vector2f scale = Vector2f(1,1);


    virtual void GameObjectUpdate(double dt) {}


    virtual void GameObjectPreDraw() {};

    virtual void GameObjectPostDraw() {};

    virtual void GameObjectSetDefaults() {};



private:
    

};