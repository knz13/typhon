#pragma once
#include "player.h"
#include "npc.h"

class Engine {
public:
    static void Initialize() {
        Player::OnPlayerCreated().Connect([](Player& plr){
            std::cout << "Created player!" << std::endl;
            Engine::players.push_back(&plr);
        }); 

        Player::OnPlayerRemoved().Connect([](Player& plr){
            std::cout << "Removed player!" << std::endl;
            Engine::players.erase(std::find(Engine::players.begin(),Engine::players.end(),&plr));
        });
    }

    static inline Vector2f mousePosition;
private:
    static inline std::vector<Player*> players = {};

};