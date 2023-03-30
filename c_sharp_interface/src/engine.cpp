#include "engine.h"
#include "TerrariaLikeGame/FlyingTreant.h"
#include "game_object_traits.h"

Vector2f Engine::mousePosition;
std::unordered_map<entt::entity,std::shared_ptr<GameObject>> Engine::aliveObjects;


void Engine::Initialize()
{
    std::cout << "initializing engine in c++" << std::endl;
    Engine::CreateNewGameObject<FlyingTreant>();
}

void Engine::Update(double dt)
{
    

}
