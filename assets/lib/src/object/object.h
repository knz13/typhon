#pragma once
#include "../utils/general.h"
#include "../utils/generic_reflection.h"
#include "../engine/entity_component_system/ecs_registry.h"

namespace Typhon
{
    namespace ObjectInternals
    {
        class ParentlessTag;
    }
    class Object
    {
    public:
        bool operator==(const Object &) const = default;

        // includes self
        void ExecuteForEveryChildInTree(std::function<void(Object &)> func, bool includeSelf = false)
        {
            if (includeSelf)
            {
                func(*this);
            }
            for (auto &id : Storage().children)
            {
                Object tempObj(id);
                if (!includeSelf)
                {
                    func(tempObj);
                }
                tempObj.ExecuteForEveryChildInTree(func, includeSelf);
            }
        }

        bool FindInChildren(Object &obj)
        {
            bool found = false;
            for (auto entity : Storage().children)
            {
                if (obj.ID() == entity)
                {
                    return true;
                }
                found = Object(entity).FindInChildren(obj);
            }
            return found;
        }

        template <typename T>
        bool HasTag()
        {
            if (!Valid())
            {
                return false;
            }
            return ECSRegistry::Get().all_of<T>(ID());
        }

        template <typename T>
        bool AddTag()
        {
            if (!Valid())
            {
                return false;
            }
            ECSRegistry::Get().emplace<T>(ID());
            return true;
        }

        template <typename T>
        bool RemoveTag()
        {
            if (!Valid())
            {
                return false;
            }
            if (!HasTag<T>())
            {
                return false;
            }
            return ECSRegistry::Get().remove<T>(ID()) > 0;
        }

        void ForEachComponent(std::function<void(Typhon::Component &)> func);

        void Clear()
        {
            RemoveFromParent();
            RemoveChildren();
        };

        void Serialize(json &val)
        {
            val["name"] = Storage().name;
            val["id"] = static_cast<int64_t>(handle);
            val["components"] = json::array();
            val["children"] = json::array();
            ForEachComponent([&](Typhon::Component &comp)
                             {
            val["components"].push_back(json::object());
            auto& compJSON = val["components"].back();
            comp.InternalSerialize(compJSON); });
            val["children"] = json::array();
            ExecuteForEveryChildInTree([&](Object &obj)
                                       {
            val["children"].push_back(json::object());
            auto& childJSON = val["children"].back();
            obj.Serialize(childJSON); });
        }

        void Deserialize(const json &val);

        bool IsChildOf(Object e)
        {
            return Storage().parent.ID() == e.ID();
        }

        bool IsMyChild(Object e)
        {
            return std::find(Storage().children.begin(), Storage().children.end(), e.ID()) != Storage().children.end();
        }

        bool HasParent()
        {
            return Storage().parent.GetAsObject().Valid();
        }

        void SetParent(Object e);

        void RemoveFromParent();

        void RemoveChild(Object e);

        void RemoveChildren();

        void AddChild(Object e);

        size_t NumberOfChildren()
        {
            return Storage().children.size();
        }

        const std::vector<entt::entity> &Children()
        {
            return Storage().children;
        };

        template <typename T>
        T *GetComponent()
        {
            return ECSRegistry::GetComponentFromEntity<T>(handle);
        }

        template <typename T, typename... Args>
        bool AddComponent(Args &&...args)
        {
            return ECSRegistry::AddComponentToEntity<T>(handle, std::forward<Args>(args)...);
        }

        template <typename T>
        bool RemoveComponent()
        {
            return ECSRegistry::EraseComponentFromEntity<T>(handle);
        }

        void EraseAllComponents()
        {
            ForEachComponent([](Typhon::Component &comp)
                             { comp.InternalDestroy(); });
        }

        std::string Name()
        {
            if (Valid())
            {
                return Storage().name;
            }
            return "Invalid Entity";
        }

        void SetName(std::string name)
        {
            if (Valid())
            {
                Storage().name = name;
            }
        }

        template <typename... Components>
        bool HasAllOf()
        {
            return ECSRegistry::Get().all_of<Components...>(handle);
        }

        template <typename... Components>
        bool HasAnyOf()
        {
            return ECSRegistry::Get().any_of<Components...>(handle);
        }

        template <typename T>
        bool HasComponent()
        {
            return ECSRegistry::Get().any_of<T>(handle);
        }

        const std::vector<std::string> &GetComponentsNames()
        {
            return Storage().componentNames;
        }

        bool Valid()
        {

            return ECSRegistry::Get().valid(handle);
        }

        entt::entity ID()
        {
            return handle;
        }

        Object(entt::entity e) : handle(e)
        {
        }

        Object() : handle() {}

    private:
        ObjectStorage &Storage()
        {
            if (!Valid())
            {
                throw;
            }
            return ECSRegistry::Get().get_or_emplace<ObjectStorage>(handle);
        }

        entt::entity handle;
    };
}