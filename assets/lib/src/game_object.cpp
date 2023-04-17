#include "game_object.h"
#include "engine.h"

std::map<int64_t,std::function<std::pair<entt::entity,std::shared_ptr<GameObject>>()>> GameObject::instantiableClasses;
std::map<int64_t,std::string> GameObject::instantiableClassesNames;
std::map<std::string,int64_t> GameObject::instantiableClassesIDs;
std::map<std::string,std::vector<GameObject*>> GameObject::instantiatedClassesPerType;

bool GameObject::Valid()
{
    return Engine::aliveObjects.find(handle) != Engine::aliveObjects.end();
}