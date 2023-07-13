#include "ecs_registry.h"
#include "object/object.h"


entt::registry ECSRegistry::registry;

bool ECSRegistry::DeleteObject(entt::entity objID) {
    if(ValidateEntity(objID)){
        Object(objID).ForEachComponent([](Component& comp){
            comp.CallDestroy();
        });
        registry.destroy(objID);
        return true;
    }
    return false;

};

