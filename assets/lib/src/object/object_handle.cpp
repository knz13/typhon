#include "object_handle.h"
#include "../engine/entity_component_system/ecs_registry.h"
#include "object.h"

namespace Typhon
{

    Object ObjectHandle::GetAsObject()
    {
        return Typhon::Object(handle);
    }

    ObjectHandle::operator bool() const
    {
        return ECSRegistry::Get().valid(handle);
    }

}
