#pragma once
#include "player.h"
#include "npc.h"

class Engine {
public:
    static void Initialize() {
        InternalPlayerStorage::OnPlayerCreated().Connect([](GameObject& plr){
            std::cout << "Created player!" << std::endl;
            Engine::players.push_back(&plr);
        }); 

        InternalPlayerStorage::OnPlayerRemoved().Connect([](GameObject& plr){
            std::cout << "Removed player!" << std::endl;
            Engine::players.erase(std::find(Engine::players.begin(),Engine::players.end(),&plr));
        });
    }



    template<typename T>
    static T& CreateNewGameObject() {
        return GameObjectMiddleMan::CreateNewGameObject<T>();
    }

    static void RemoveGameObject(GameObject other){
        GameObjectMiddleMan::RemoveGameObject(other);
    }

    static void RemoveGameObjectByID(int64_t id){
        GameObjectMiddleMan::RemoveGameObjectByID(id);
    }

    static inline Vector2f mousePosition;
private:
    static inline std::vector<GameObject*> players = {};

};