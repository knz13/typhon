#pragma once
#include "gameobject_middle_man.h"
#include <chrono>
#include "entt/entt.hpp"


class GameObject : public GameObjectMiddleMan {
public:


    template<typename T>
    static T& CreateNewGameObject() {
        int64_t id = GameObjectMiddleMan::createGameObjectAndGetID();
        std::cout << "Creating object with id " << id << " and type " << HelperFunctions::GetClassNameString<T>() <<  std::endl;

        if(GameObject::aliveObjects.find(id) == GameObject::aliveObjects.end()){
            GameObject::aliveObjects[id] = std::unique_ptr<GameObjectMiddleMan>(new T());
            GameObject::aliveObjects[id].get()->identifier = id;
            GameObject::aliveObjects[id].get()->className = HelperFunctions::GetClassNameString<T>();

            
            std::cout << "Created player! Checking if keys callback registered!" << std::endl;
            GameObjectMiddleMan::attachPointersToObject(id);

            if(GameObjectMiddleMan::classesThatHaveHasKeyCallbacks.find(HelperFunctions::GetClassNameString<T>())
                != GameObjectMiddleMan::classesThatHaveHasKeyCallbacks.end()){
                std::cout << "Registering keys callback!" << std::endl;
                GameObjectMiddleMan::objectsToCallKeysCallback[id] = GameObject::aliveObjects[id].get();
            }
        }
        else{
            std::cout << "Tried to create gameobject with id " << id << " but some other with this id already exists!!" << std::endl;
        }
        return (T&)(*GameObject::aliveObjects[id].get());
    }

    static void RemoveGameObject(GameObject other){
        int64_t id = other.identifier;  
        if(GameObjectMiddleMan::aliveObjects.find(id) != GameObjectMiddleMan::aliveObjects.end()){
            std::cout << "removing object with id = " << id << std::endl;
            if(GameObjectMiddleMan::objectsToCallKeysCallback.find(id) != GameObjectMiddleMan::objectsToCallKeysCallback.end()){
                GameObjectMiddleMan::objectsToCallKeysCallback.erase(id);
            }
            GameObjectMiddleMan::aliveObjects[id].get()->OnRemove();
            GameObjectMiddleMan::aliveObjects.erase(id);
        }
    }

    static void RemoveGameObjectByID(int64_t id){
        if(GameObjectMiddleMan::aliveObjects.find(id) != GameObjectMiddleMan::aliveObjects.end()){
            std::cout << "removing object with id = " << id << std::endl;
            if(GameObjectMiddleMan::objectsToCallKeysCallback.find(id) != GameObjectMiddleMan::objectsToCallKeysCallback.end()){
                GameObjectMiddleMan::objectsToCallKeysCallback.erase(id);
            }
            GameObjectMiddleMan::aliveObjects[id].get()->OnRemove();
            GameObjectMiddleMan::aliveObjects.erase(id);
        }
        else{
            std::cout << "Trying to delete an object with an invalid id!" << std::endl;
            std::cout << "id = " << id << std::endl;
        }
    }

    template<typename T>
    static void AddToHierarchyMenu() {
        std::string name = HelperFunctions::GetClassNameString<T>();
        if(GameObjectMiddleMan::menuOptionsStringToOnClick.find(name) != GameObjectMiddleMan::menuOptionsStringToOnClick.end()){
            return;
        }

        std::cout << "adding to hierarchy menu: " << name << std::endl;

        GameObjectMiddleMan::menuOptionsIDtoString[Random::get()] = name;
        GameObjectMiddleMan::menuOptionsStringToOnClick[name] = [](){
            GameObject::CreateNewGameObject<T>();
        };
    }


    


private:
    using GameObjectMiddleMan::className;
    using GameObjectMiddleMan::OnRemove;
    using GameObjectMiddleMan::aliveObjects;
    using GameObjectMiddleMan::menuOptionsIDtoString;
    using GameObjectMiddleMan::menuOptionsStringToOnClick;
    using GameObjectMiddleMan::staticDefaultsFuncs;
    using GameObjectMiddleMan::onCallAI;
    using GameObjectMiddleMan::onCallFindFrame;
    using GameObjectMiddleMan::onCallUpdate;
    using GameObjectMiddleMan::onCallPostDraw;
    using GameObjectMiddleMan::onCallPreDraw;
    using GameObjectMiddleMan::onCallSetDefaults;
    using GameObjectMiddleMan::createGameObjectAndGetID;
    using GameObjectMiddleMan::_positionX;
    using GameObjectMiddleMan::_positionY;
    using GameObjectMiddleMan::_scalePointerX;
    using GameObjectMiddleMan::_scalePointerY;
};

