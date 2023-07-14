#include "object_handle.h"
#include "../ecs_registry.h"
#include "object.h"


Typhon::Object ObjectHandle::GetAsObject() {
    return Typhon::Object(handle);
}

ObjectHandle::operator bool() const {
    return ECSRegistry::Get().valid(handle);
}