#include "object.h"
#include "../engine.h"

void Object::Deserialize(const json& val) {
    if (val.contains("name")) {
        Storage().name = val["name"];
    }

    Clear();
    
    /* 
    TODO
    if (val.contains("components")) {
        for (const auto& compJSON : val["components"]) {
            Component& comp = AddComponent();
            comp.Deserialize(compJSON);
        }
    } */

    if (val.contains("children")) {
        for (const auto& childJSON : val["children"]) {
            if(childJSON.contains("name")){
                Object obj = Engine::CreateObject();
                AddChild(obj);
                obj.Deserialize(childJSON);
            }
        }
    }
}