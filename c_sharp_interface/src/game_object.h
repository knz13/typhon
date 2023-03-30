#pragma once
#include "general.h"
#include "reflection_checks.h"
#include "ecs_registry.h"


class GameObject {
public:

    bool Valid();

    template<typename T>
    std::optional<T&> GetAs() {
        if(!Valid()) {
            return {};
        }

        T* testValue = dynamic_cast<T*>(this);
        if(testValue != nullptr){
            return *testValue;
        }
        return {};
    }


private:
    entt::entity handle = entt::null;

    virtual void GameObjectOnCreate() {};
    virtual void GameObjectOnDestroy() {};


    friend class Engine;
};

DEFINE_HAS_SIGNATURE(has_on_create,T::OnCreate,void (T::*) ());
DEFINE_HAS_SIGNATURE(has_on_destroy,T::OnDestroy,void (T::*) ());


template<typename... DerivedClasses> 
class DerivedFromGameObject : public GameObject {
public:

private:

    template<typename A>
    void GameObjectOnCreateForOne() {
        if constexpr (has_on_create<A>::value){
            A::OnCreate():
        }
    }

    template<typename A>
    void GameObjectOnDestroyForOne() {
        if constexpr (has_on_destroy<A>::value){
            A::OnDestroy():
        }
    }


    void GameObjectOnCreate() override{
        (GameObjectOnCreateForOne<DerivedClasses>(),...);
    };
    

    void GameObjectOnDestroy() override {
        (GameObjectOnDestroyForOne<DerivedClasses>(),...);
    };


    friend class Engine;
};