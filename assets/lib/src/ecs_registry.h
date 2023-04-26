#pragma once
#include "general.h"

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

class ObjectStorage { 
private:

    std::vector<std::string> componentNames = {};
    ObjectHandle parent = {};
    ObjectHandle master = {};
    std::vector<entt::entity> children = {};

    friend class ECSRegistry;
    friend class Object;
};

class ECSRegistry {
public:
    static entt::registry& Get() {
        return registry;
    }

    static entt::entity CreateEntity() {
        entt::entity e = registry.create();
        auto& storage = registry.emplace<ObjectStorage>(e);
        storage.master = e;
        return e;
    };

    static void Clear() {
        registry.clear();
    }

private:
    static entt::registry registry;

};