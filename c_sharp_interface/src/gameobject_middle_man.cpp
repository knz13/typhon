#include "gameobject_middle_man.h"
#include "gameobject.h"


void GameObjectMiddleMan::onCallToRemoveObject(int64_t id) {
    GameObject::RemoveGameObjectByID(id);
}