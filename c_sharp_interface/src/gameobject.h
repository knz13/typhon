#pragma once
#include "gameobject_middle_man.h"
#include <chrono>


class GameObject : public GameObjectMiddleMan {
public:
    template<typename T>
    static T& CreateNewGameObject() {
        int64_t id = GameObjectMiddleMan::createGameObjectAndGetID();
        std::cout << "Creating object with id " << id << " and type " << typeid(T).name() <<  std::endl;

        if(GameObject::aliveObjects.find(id) == GameObject::aliveObjects.end()){
            GameObject::aliveObjects[id] = std::unique_ptr<GameObjectMiddleMan>(new T());
        }
        else{
            std::cout << "Tried to create gameobject with id " << id << " but some other with this id already exists!!" << std::endl;
        }
        return (T&)(*GameObject::aliveObjects[id].get());
    }

    template<typename T>
    static void AddToHierarchyMenu() {

        if(GameObjectMiddleMan::menuOptionsStringToOnClick.find(typeid(T).name()) != GameObjectMiddleMan::menuOptionsStringToOnClick.end()){
            return;
        }

        std::cout << "adding to hierarchy menu: " << typeid(T).name() << std::endl;

        GameObjectMiddleMan::menuOptionsIDtoString[std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count()] = typeid(T).name();
        GameObjectMiddleMan::menuOptionsStringToOnClick[typeid(T).name()] = [](){
            GameObject::CreateNewGameObject<T>();
        };
    }


private:
    using GameObjectMiddleMan::_positionX;
    using GameObjectMiddleMan::_positionY;
    using GameObjectMiddleMan::_scalePointerX;
    using GameObjectMiddleMan::_scalePointerY;
};

