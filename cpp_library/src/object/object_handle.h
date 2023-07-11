#pragma once
#include "../general.h"

class Object;
class ObjectHandle {
public:
    ObjectHandle(entt::entity e) : handle(e) {};

    ObjectHandle() {};

    Object GetAsObject();

    entt::entity ID() {
        return handle;
    }

    operator bool() const;

private:
    entt::entity handle = entt::null;
};