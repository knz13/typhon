#include "game_object.h"
#include "engine.h"

bool GameObject::Valid()
{
    return Engine::aliveObjects.find(handle) != Engine::aliveObjects.end();
}