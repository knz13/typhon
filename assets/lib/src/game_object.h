#pragma once
#include "general.h"
#include "reflection_checks.h"
#include "generic_reflection.h"
#include "ecs_registry.h"

DEFINE_HAS_SIGNATURE(has_set_defaults_function,T::SetDefaults,void (T::*)());


template<typename MainClass,typename... DerivedClasses>
class DerivedFromGameObject;

class GameObject {
public:

    static const std::map<int64_t,std::function<std::pair<entt::entity,std::shared_ptr<GameObject>>()>>& GetInstantiableClassesFunctions() {
        return instantiableClasses;
    }
    static const std::map<int64_t,std::string> GetInstantiableClassesIDsToNames() {
        return instantiableClassesNames;
    }

    bool Valid();

    const std::string& ClassName() {
        return className;
    }

    entt::entity Handle(){
        return handle;
    }

    yael::event_sink<void()> OnBeingDestroyed() {
        return onDestroyEvent.Sink();
    }

protected:

private:
    static std::map<int64_t,std::function<std::pair<entt::entity,std::shared_ptr<GameObject>>()>> instantiableClasses;
    static std::map<int64_t,std::string> instantiableClassesNames;
    static std::map<std::string,int64_t> instantiableClassesIDs;

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
public:
    virtual void ExecuteOnObjectCreationInternal(GameObject* ptr) {};


    friend class Engine;
};




template<typename MainClass,typename... DerivedClasses> 
class DerivedFromGameObject : public GameObject,public Reflection::IsInitializedStatically<DerivedFromGameObject<MainClass,DerivedClasses...>>,public DerivedClasses... {
public:
    static void InitializeStatically() {
        GameObject::instantiableClasses[HelperFunctions::GetClassID<MainClass>()] = [](){
            entt::entity e = ECSRegistry::Get().create();
            auto ptr = std::shared_ptr<GameObject>(static_cast<GameObject*>(new MainClass()));
            ptr.get()->handle = e;
            ptr.get()->GameObjectOnCreate();

            if constexpr (std::is_base_of<OnBeignBaseOfObjectInternal,MainClass>::value) {
                static_cast<OnBeignBaseOfObjectInternal*>(static_cast<MainClass*>(ptr.get()))->ExecuteOnObjectCreationInternal(ptr.get());
            }

            if constexpr (has_set_defaults_function<MainClass>::value){
                static_cast<MainClass*>(ptr.get())->SetDefaults();
            }

            return std::make_pair(e,ptr);
        };
        GameObject::instantiableClassesIDs[HelperFunctions::GetClassNameString<MainClass>()] = HelperFunctions::GetClassID<MainClass>();
        GameObject::instantiableClassesNames[HelperFunctions::GetClassID<MainClass>()] = HelperFunctions::GetClassNameString<MainClass>();
    };

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


    void GameObjectOnCreate() override {
        className = HelperFunctions::GetClassNameString<MainClass>();

        GameObjectOnCreateForOne<MainClass>();
        (GameObjectOnCreateForOne<DerivedClasses>(),...);
    };
    

    void GameObjectOnDestroy() override {

        GameObject::GameObjectOnDestroy();
        
        GameObjectOnDestroyForOne<MainClass>();
        (GameObjectOnDestroyForOne<DerivedClasses>(),...);
    };
private:
    
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
            static_cast<A*>(static_cast<NthTypeOf<Reflection::IndexOfTopClass<DerivedClasses...>(),DerivedClasses...>*>(this))->ExecuteOnObjectCreation(ptr);
        }
    }



};