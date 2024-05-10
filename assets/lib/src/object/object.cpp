#include "object.h"
#include "../engine/engine.h"
#include "../component/make_component.h"

void Typhon::Object::Deserialize(const json &val)
{
    if (val.contains("name"))
    {
        Storage().name = val["name"];
    }

    Clear();

    /*
    TODO
    if (val.contains("components")) {
        for (const auto& compJSON : val["components"]) {
            Typhon::Component& comp = AddComponent();
            comp.Deserialize(compJSON);
        }
    } */

    if (val.contains("children"))
    {
        for (const auto &childJSON : val["children"])
        {
            if (childJSON.contains("name"))
            {
                Typhon::Object obj = Engine::CreateObject();
                AddChild(obj);
                obj.Deserialize(childJSON);
            }
        }
    }
}

void Typhon::Object::ForEachComponent(std::function<void(Typhon::Component &)> func)
{
    if (!Valid())
    {
        return;
    }
    for (auto [name, storage] : ECSRegistry::Get().storage())
    {
        bool foundStorageType = std::find(ComponentInternals::ComponentStatics::componentTypes.begin(), ComponentInternals::ComponentStatics::componentTypes.end(), name) != ComponentInternals::ComponentStatics::componentTypes.end();
        if (storage.contains(ID()) && storage.type() != entt::type_id<ObjectStorage>() && foundStorageType)
        {
            func(*((Typhon::Component *)storage.get(ID())));
        }
    }
}

void Typhon::Object::SetParent(Object e)
{
    if (!(e.Valid() || this->Valid()))
    {
        return;
    }
    RemoveFromParent();
    if (FindInChildren(e))
    {
        e.RemoveFromParent();
    }

    Storage().parent = e.ID();
    if (e.Valid() && this->Valid() && std::find(e.Storage().children.begin(), e.Storage().children.end(), ID()) == e.Storage().children.end())
    {
        e.Storage().children.push_back(ID());
        if (HasTag<ObjectInternals::ParentlessTag>())
        {
            RemoveTag<ObjectInternals::ParentlessTag>();
        }
        EngineInternals::onChildrenChangedFunc();
    }
}

void Typhon::Object::RemoveFromParent()
{
    if (Storage().parent)
    {
        auto &children = Storage().parent.GetAsObject().Storage().children;
        children.erase(std::find(children.begin(), children.end(), ID()));
        AddTag<ObjectInternals::ParentlessTag>();
        Storage().parent = ObjectHandle();
        EngineInternals::onChildrenChangedFunc();
    }
}

void Typhon::Object::RemoveChild(Object e)
{
    auto pos = std::find(Storage().children.begin(), Storage().children.end(), e.ID());
    if (pos != Storage().children.end())
    {
        Object(*pos).Storage().parent = ObjectHandle();
        Storage().children.erase(pos);
        Object(*pos).AddTag<ObjectInternals::ParentlessTag>();
        EngineInternals::onChildrenChangedFunc();
    }
}

void Typhon::Object::RemoveChildren()
{
    auto it = Storage().children.begin();
    while (it != Storage().children.end())
    {
        Object(*it).Storage().parent = ObjectHandle();
        Storage().children.erase(it);
        Object(*it).AddTag<ObjectInternals::ParentlessTag>();
        it = Storage().children.begin();
    }
    EngineInternals::onChildrenChangedFunc();
}

void Typhon::Object::AddChild(Object e)
{
    auto pos = std::find(Storage().children.begin(), Storage().children.end(), e.ID());
    if (pos == Storage().children.end())
    {
        Storage().children.push_back(e.ID());
        e.Storage().parent = this->ID();
        e.RemoveTag<ObjectInternals::ParentlessTag>();
        EngineInternals::onChildrenChangedFunc();
    }
}