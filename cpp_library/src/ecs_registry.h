#pragma once
#include "general.h"
#include "component/component.h"
#include "object/object_storage.h"


template<typename T>
class MakeComponent;

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

    static bool DeleteObject(entt::entity objID);


    static void Clear() {
        registry.clear();

    }

    static ObjectStorage* GetStorageForEntity(entt::entity e) {
        if(!ValidateEntity(e)){
            std::cout << "returning nullptr from get storage for entity" << std::endl;
            return nullptr;
        }
        
        return &registry.get<ObjectStorage>(e);
    }

    static bool ValidateEntity(entt::entity e) {
        return registry.valid(e);
    }

    template<typename... Args>
    static bool HasAnyOf(entt::entity e) {
        return registry.any_of<Args...>(e);
    }

    template<typename T,typename... Args>
    static bool AddComponentToEntity(entt::entity e,Args&&... args) {
        static_assert(std::is_base_of<MakeComponent<T>,T>::value,"This class is not derived from MakeComponent, therefore it cannot be used as a component");
        if(!ValidateEntity(e)){
            return false;
        }
        if(HasAnyOf<T>(e)){
            return true;
        }

        T& obj = ECSRegistry::Get().emplace_or_replace<T>(e, std::forward<Args>(args)...);
        static_cast<Component*>(&obj)->removeFromObjectFunc = [=](){
            ECSRegistry::Get().remove<T>(e);
        };
        static_cast<Component*>(&obj)->CallCreate();
        GetStorageForEntity(e)->componentNames.push_back(HelperFunctions::GetClassNameString<T>());
        return true;
    }

    template<typename T>
    static T* GetComponentFromEntity(entt::entity e) {
        if(!ValidateEntity(e)){
            return nullptr;
        }
        if(!HasAnyOf<T>(e)){
            return nullptr;
        }

        return &ECSRegistry::Get().get<T>(e);
    }

    template<typename T>
    static bool EraseComponentFromEntity(entt::entity e) {
        static_assert(std::is_base_of<MakeComponent<T>,T>::value,"This class is not derived from MakeComponent, therefore it couldn't even be added as a component");
        if(!ValidateEntity(e)){
            return false;
        }
        if(!HasAnyOf<T>(e)){
            return false;
        }
        
        static_cast<Component*>(GetComponentFromEntity<T>(e))->CallDestroy();

        return true;
    }



private:
    static entt::registry registry;

    template<typename>
    friend class MakeComponent;
};



