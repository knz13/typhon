#include "object.h"
#include "../engine.h"
#include "../component/make_component.h"

void Typhon::Object::Deserialize(const json& val) {
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
                Typhon::Object obj = Engine::CreateObject();
                AddChild(obj);
                obj.Deserialize(childJSON);
            }
        }
    }
}

void Typhon::Object::ForEachComponent(std::function<void(Component&)> func){
    if(!Valid()){
        return;
    }
    for(auto [name,storage] : ECSRegistry::Get().storage()){
        bool foundStorageType = std::find(ComponentInternals::ComponentStatics::componentTypes.begin(),ComponentInternals::ComponentStatics::componentTypes.end(),name) != ComponentInternals::ComponentStatics::componentTypes.end();
        if(storage.contains(ID()) && storage.type() != entt::type_id<ObjectStorage>() && foundStorageType){
            func(*((Component*)storage.get(ID())));
        }

    }
}


void Typhon::Object::SetParent(Object e) {
    Storage().parent = e.ID();
    if(e.Valid() && this->Valid()){
        e.Storage().children.push_back(ID());
        if(HasTag<ObjectInternals::ParentlessTag>()){
            RemoveTag<ObjectInternals::ParentlessTag>();
        }
    }
}

void Typhon::Object::RemoveFromParent() {
    if(Storage().parent){
        auto& children = Storage().parent.GetAsObject().Storage().children;
        children.erase(std::find(children.begin(),children.end(),ID()));
        AddTag<ObjectInternals::ParentlessTag>();
    }
    Storage().parent = ObjectHandle();
}

void Typhon::Object::RemoveChild(Object e) {
    auto pos = std::find(Storage().children.begin(),Storage().children.end(),e.ID());
    if(pos != Storage().children.end()){
        Object(*pos).Storage().parent = ObjectHandle();
        Storage().children.erase(pos);
        Object(*pos).AddTag<ObjectInternals::ParentlessTag>();
    }
}

void Typhon::Object::RemoveChildren() {
    auto it = Storage().children.begin();
    while(it != Storage().children.end()){
        Object(*it).Storage().parent = ObjectHandle();
        Storage().children.erase(it);
        Object(*it).AddTag<ObjectInternals::ParentlessTag>();
        it = Storage().children.begin();
    }
}


void Typhon::Object::AddChild(Object e) {
    auto pos =std::find(Storage().children.begin(),Storage().children.end(),e.ID());
    if (pos == Storage().children.end()) {
        Storage().children.push_back(e.ID());
        e.Storage().parent = this->ID();
        e.RemoveTag<ObjectInternals::ParentlessTag>();
    }
}