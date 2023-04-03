#pragma once
#include "general.h"
#include "reflection_checks.h"
#include "ecs_registry.h"

template<typename MainClass,typename... DerivedClasses>
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

protected:

private:
    std::string className = "";
    yael::event_launcher<void()> onDestroyEvent;
    entt::entity handle = entt::null;
    

    virtual void GameObjectOnCreate() {};
    virtual void GameObjectOnDestroy() {
        onDestroyEvent.EmitEvent();
    };

    template<typename MainClass,typename... DerivedClasses>
    friend class DerivedFromGameObject;
    friend class Engine;
};

DEFINE_HAS_SIGNATURE(has_on_create,T::Create,void (T::*) ());
DEFINE_HAS_SIGNATURE(has_on_destroy,T::Destroy,void (T::*) ());



   


template<typename MainClass,typename... DerivedClasses> 
class DerivedFromGameObject : public GameObject,public DerivedClasses... {
public:
    

private:

    template<typename A>
    void GameObjectOnCreateForOne() {
        std::cout << "executing on create for class " << HelperFunctions::GetClassNameString<A>() << std::endl;
        if constexpr (has_on_create<A>::value){
            static_cast<A*>(static_cast<MainClass*>(this))->Create();
        }
    }

    template<typename A>
    void GameObjectOnDestroyForOne() {
        std::cout << "executing on destroy for class " << HelperFunctions::GetClassNameString<A>() << std::endl;
        if constexpr (has_on_destroy<A>::value){
            static_cast<A*>(static_cast<MainClass*>(this))->Destroy();
        }
    }


    void GameObjectOnCreate() override{
        className = HelperFunctions::GetClassNameString<MainClass>();

        (GameObjectOnCreateForOne<DerivedClasses>(),...);
    };
    

    void GameObjectOnDestroy() override {

        GameObject::GameObjectOnDestroy();
        
        (GameObjectOnDestroyForOne<DerivedClasses>(),...);
    };
private:
    
    friend class Engine;
};

template<typename... Others>
constexpr bool CheckIfDerivedFromGameObject() {
    return (std::is_base_of<GameObject,Others>::value || ...);
};


template<typename... DerivedClasses>
class ConditionedOnGameObject {
public:
    ConditionedOnGameObject() {
        static_assert(CheckIfDerivedFromGameObject<DerivedClasses...>(),"You've used a class that is derived from ConditionedOnGameObject without also deriving from GameObject, please add it or one of its derived classes");
    }



};

class OnBeignBaseOfObjectInternal{
protected:
    virtual void ExecuteOnObjectCreationInternal(GameObject* ptr) {};


    friend class Engine;
};






template<typename... DerivedClasses>
class HasOnBeingBaseOfObject : public OnBeignBaseOfObjectInternal, public ConditionedOnGameObject<DerivedClasses...> {

    void ExecuteOnObjectCreationInternal(GameObject* ptr) override {

        (ExecuteForOneClass<DerivedClasses>(ptr),...);
    }


public:
    HasOnBeingBaseOfObject() {
    }

private:

    template<typename A>
    void ExecuteForOneClass(GameObject* ptr) {
        constexpr bool has_execute_on_object_creation = requires(A& t,GameObject* pointer) {
            t.ExecuteOnObjectCreation(pointer);
        };

        
        if constexpr (has_execute_on_object_creation){

            //std::cout << "trying to executing on beign base on object of type " << HelperFunctions::GetClassNameString<A>() << std::endl;
            static_cast<A*>(static_cast<NthTypeOf<IndexOfTopClass<DerivedClasses...>(),DerivedClasses...>*>(this))->ExecuteOnObjectCreation(ptr);
        }
    }



};