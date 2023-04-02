#include "engine.h"
#include "TerrariaLikeGame/FlyingTreant.h"
#include "game_object_traits.h"

Vector2f Engine::mousePosition;
std::unordered_map<entt::entity,std::shared_ptr<GameObject>> Engine::aliveObjects;
std::bitset<std::size(Keys::IndicesOfKeys)> Engine::keysPressed;


void Engine::Initialize()
{
    std::cout << "initializing engine in c++" << std::endl;
    Engine::CreateNewGameObject<FlyingTreant>();
}

void Engine::Update(double dt)
{
    for(const auto& [handle,func] : Traits::HasUpdate<Reflection::NullClassHelper>::objectsThatNeedUpdate) {
        func(dt);
    } 

}

void Engine::PushKeyDown(int64_t key)
{      
    auto indexOfKey = std::find(Keys::IndicesOfKeys.begin(),Keys::IndicesOfKeys.end(),key);
    
    if(indexOfKey == Keys::IndicesOfKeys.end()){
        std::cout << "tried to push a key into the keys pressed stack with a wrong id!" << std::endl;
    }
    keysPressed[indexOfKey - Keys::IndicesOfKeys.begin()] = 1;
}

void Engine::PushKeyUp(int64_t key)
{
    auto indexOfKey = std::find(Keys::IndicesOfKeys.begin(),Keys::IndicesOfKeys.end(),key);
    
    if(indexOfKey == Keys::IndicesOfKeys.end()){
        std::cout << "tried to push a key into the keys pressed stack with a wrong id!" << std::endl;
    }
    keysPressed[indexOfKey - Keys::IndicesOfKeys.begin()] = 0;
}

bool Engine::IsKeyPressed(InputKey key)
{
    auto indexOfKey = std::find(Keys::IndicesOfKeys.begin(),Keys::IndicesOfKeys.end(),key);

    return keysPressed[indexOfKey - Keys::IndicesOfKeys.begin()];
}
