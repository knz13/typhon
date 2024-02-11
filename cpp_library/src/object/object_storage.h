#pragma once
#include "../utils/general.h"
#include "object_handle.h"

namespace Typhon
{

    class ObjectStorage
    {
    private:
        std::vector<std::string> componentNames = {};
        Typhon::ObjectHandle parent = {};
        Typhon::ObjectHandle master = {};
        std::vector<entt::entity> children = {};
        std::string name = "Empty Object";

        friend class ECSRegistry;
        friend class Typhon::Object;
    };
}