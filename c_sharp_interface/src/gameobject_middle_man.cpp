#include "gameobject_middle_man.h"
#include "gameobject.h"


void GameObjectMiddleMan::onCallToRemoveObject(int64_t id) {
    if(GameObjectMiddleMan::objectsBeingDeleted.find(id) != GameObjectMiddleMan::objectsBeingDeleted.end()){
        std::cout << "Trying to delete an object with id " << id << " that is already being deleted!" << std::endl;
        return;
    }

    GameObject::RemoveGameObjectByID(id);
}