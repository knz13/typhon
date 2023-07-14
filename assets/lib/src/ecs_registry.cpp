#include "ecs_registry.h"
#include "object/object.h"


entt::registry ECSRegistry::registry;

bool ECSRegistry::DeleteObject(entt::entity objID) {
    if(ValidateEntity(objID)){
        Typhon::Object(objID).ForEachComponent([](Component& comp){
            comp.InternalDestroy();
        });
        registry.destroy(objID);
        return true;
    }
    return false;

};

