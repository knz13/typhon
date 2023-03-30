#pragma once
#include "general.h"
#include "reflection_checks.h"
#include "ecs_registry.h"

template<typename... DerivedClasses> 
class DerivedFromGameObject;

class GameObject {
public:

    bool Valid();
    entt::entity Handle(){
        return handle;
    }

    yael::event_sink<void()> OnBeingDestroyed() {
        return onDestroyEvent.Sink();
    }

private:
    yael::event_launcher<void()> onDestroyEvent;
    entt::entity handle = entt::null;

    virtual void GameObjectOnCreate() {};
    virtual void GameObjectOnDestroy() {
        onDestroyEvent.EmitEvent();
    };

    template<typename... DerivedClasses> 
    friend class DerivedFromGameObject;
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
        std::cout << "executing on create for class " << HelperFunctions::GetClassNameString<A>() << std::endl;
        if constexpr (has_on_create<A>::value){
            static_cast<A*>(this)->OnCreate();
        }
    }

    template<typename A>
    void GameObjectOnDestroyForOne() {
        std::cout << "executing on create for class " << HelperFunctions::GetClassNameString<A>() << std::endl;
        if constexpr (has_on_destroy<A>::value){
            static_cast<A*>(this)->OnDestroy();
        }
    }


    void GameObjectOnCreate() override{
        (GameObjectOnCreateForOne<DerivedClasses>(),...);
    };
    

    void GameObjectOnDestroy() override {

        GameObject::GameObjectOnDestroy();
        
        (GameObjectOnDestroyForOne<DerivedClasses>(),...);
    };
private:
    
    friend class Engine;
};


class OnBeignBaseOfObjectInternal {
protected:
    virtual void ExecuteOnObjectCreationInternal(GameObject* ptr) {};


    friend class Engine;
};

DEFINE_HAS_SIGNATURE(has_execute_on_object_creation,T::ExecuteOnObjectCreation, void (T::*) (GameObject*));

template<typename... DerivedClasses>
class HasOnBeingBaseOfObject : public OnBeignBaseOfObjectInternal {

    void ExecuteOnObjectCreationInternal(GameObject* ptr) override {

        (ExecuteForOneClass<DerivedClasses>(ptr),...);
    }


public:
    HasOnBeingBaseOfObject() {
    }

private:

    template<typename A>
    void ExecuteForOneClass(GameObject* ptr) {
        //std::cout << "trying to execute on beign base on object of type " << HelperFunctions::GetClassNameString<A>() << std::endl;
        if constexpr (has_execute_on_object_creation<A>::value){

            static_cast<A*>(this)->ExecuteOnObjectCreation(ptr);
        }
    }



};