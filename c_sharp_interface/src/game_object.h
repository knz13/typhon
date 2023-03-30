#pragma once
#include "general.h"
#include "reflection_checks.h"
#include "ecs_registry.h"


class GameObject {
public:

    bool Valid();

    entt::sink<entt::sigh<void (void (&)()), std::__1::allocator<void>>> OnBeingDestroyed() {
        return onDestroyEvent.sink<void()>();
    }

protected:
    entt::dispatcher onDestroyEvent;
private:
    entt::entity handle = entt::null;

    virtual void GameObjectOnCreate() {};
    virtual void GameObjectOnDestroy() {


    };

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

        onDestroyEvent.update();
        
        (GameObjectOnDestroyForOne<DerivedClasses>(),...);
    };
private:
    using GameObject::onDestroyEvent;
    
    friend class Engine;
};


class OnBeignBaseOfObjectInternal {
protected:
    virtual void ExecuteOnObjectCreationInternal(GameObject* ptr) {};


    friend class Engine;
}

DEFINE_HAS_SIGNATURE(has_execute_on_object_creation,T::ExecuteOnObjectCreation, void (T::*) (GameObject*));

template<typename... DerivedClasses>
class HasOnBeingBaseOfObject {

    void ExecuteOnObjectCreationInternal(GameObject* ptr) {

        (ExecuteForOneClass<DerivedClasses>(ptr),...);
    }
private:

    template<typename A>
    void ExecuteForOneClass(GameObject* ptr) {
        if constexpr (has_execute_on_object_creation<A>::value){

            A::ExecuteOnObjectCreation(ptr);
        }
    }



}