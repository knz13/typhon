#pragma once
#include "../utils/general.h"

namespace Typhon
{
    class Object;

    class ObjectHandle
    {
    public:
        ObjectHandle(entt::entity e) : handle(e){};

        ObjectHandle(){};

        Typhon::Object GetAsObject();

        entt::entity ID()
        {
            return handle;
        }

        operator bool() const;

    private:
        entt::entity handle = entt::null;
    };

}
