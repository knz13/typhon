#include "object_handle.h"


Object ObjectHandle::GetAsObject() {
    return Object(handle);
}

ObjectHandle::operator bool() const {
    return ECSRegistry::Get().valid(handle);
}