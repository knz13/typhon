#pragma once
#include "../general.h"
#include "object_handle.h"

class ObjectStorage { 
private:

    std::vector<std::string> componentNames = {};
    ObjectHandle parent = {};
    ObjectHandle master = {};
    std::vector<entt::entity> children = {};
    std::string name = "Empty Object";
    

    friend class ECSRegistry;
    friend class Typhon::Object;
};