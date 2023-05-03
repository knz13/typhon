#include "ecs_registry.h"
#include "object.h"


entt::registry ECSRegistry::registry;

Object ObjectHandle::GetAsObject() {
    return Object(handle);
}

ObjectHandle::operator bool() const {
    return ECSRegistry::Get().valid(handle);
}
