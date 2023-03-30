#pragma once
#include "general.h"
#include "generic_reflection.h"
#include "game_object.h"
#include "ecs_registry.h"

class Engine {
public:
    static void Initialize();

    template<typename T>
    static T& CreateNewGameObject() {
        static_assert(std::is_base_of<GameObject,T>::value,"Can only create Game Objects that are derived from GameObject");
        entt::entity e = ECSRegistry::Get().create();
        aliveObjects[e] = T();
        static_cast<GameObject*>(&aliveObjects[e])->handle = e;
        static_cast<GameObject*>(&aliveObjects[e])->GameObjectOnCreate();

        if(std::is_base_of<OnBeignBaseOfObjectInternal,T>::value) {
            static_cast<OnBeignBaseOfObjectInternal*>(&aliveObjects[e])->ExecuteOnObjectCreationInternal();
        }

        return aliveObjects[e];
    };

    static bool RemoveGameObject(GameObject obj) {
        if(!obj.Valid()){
            std::cout << "Could not remove gameobject, invalid id!" << std::endl;
            return false;
        }
        

        aliveObjects.erase(obj.handle);
        ECSRegistry::Get().destroy(obj.handle);
        return true;
    }

    static bool RemoveGameObjectFromHandle(entt::entity e) {
        if(aliveObjects.find(e) == aliveObjects.end()){
            std::cout << "Could not remove gameobject, invalid id!" << std::endl;
            return false;
        }
        aliveObjects.erase(e);
        ECSRegistry::Get().destroy(e);
        return true;
    }

    
private:
    static std::unordered_map<entt::entity,GameObject> aliveObjects;
    static Vector2f mousePosition;


    friend class GameObject;

};
