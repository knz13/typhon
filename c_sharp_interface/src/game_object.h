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

    static const std::map<int64_t,std::function<std::pair<int64_t,std::shared_ptr<GameObject>>()>>& GetInstantiableClassesFunctions() {
        return instantiableClasses;
    }
    static const std::map<int64_t,std::string> GetInstantiableClassesIDsToNames() {
        return instantiableClassesNames;
    }




    bool Valid();

    const std::string& Name() {
        return name;
    }

    const std::string& ClassName() {
        return className;
    }

    int64_t Handle(){
        return handle;
    }

    yael::event_sink<void()> OnBeingDestroyed() {
        return onDestroyEvent.Sink();
    }

    void Serialize(json& jsonData) {
        GameObjectSerialize(jsonData);
    }

    void Deserialize(const json& jsonData) {
        GameObjectDeserialize(jsonData);
    }

protected:

private:
    static std::map<int64_t,std::function<std::pair<int64_t,std::shared_ptr<GameObject>>()>> instantiableClasses;
    static std::map<int64_t,std::string> instantiableClassesNames;
    static std::map<std::string,int64_t> instantiableClassesIDs;
    static std::map<std::string,std::vector<GameObject*>> instantiatedClassesPerType;

    std::string className = "";
    std::string name = "";
    yael::event_launcher<void()> onDestroyEvent;
    int64_t handle = -1;
    

    virtual void GameObjectSerialize(json& json) {};
    virtual void GameObjectDeserialize(const json& jsonData) {};
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
DEFINE_HAS_SIGNATURE(has_serialize,T::Serialize,void (T::*) (json&));
DEFINE_HAS_SIGNATURE(has_deserialize,T::Deserialize,void (T::*) (const json&));



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
            int64_t e = Random::get<int64_t>();
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
    void GameObjectSerializeForOne(json& jsonData) {
        
        constexpr bool hasInternalToJsonFunc = requires (json& j,A& a) {
            a.InternalSerialize(j);
        };
        if constexpr (std::is_same<A,MainClass>::value){
            if constexpr (has_serialize<A>::value) {
                std::cout << "executing serialize for class " << HelperFunctions::GetClassNameString<A>() << std::endl;
                json& jsonInner = jsonData[HelperFunctions::GetClassNameString<A>()];
                static_cast<A*>(static_cast<MainClass*>(this))->Serialize(jsonInner);
            }
            else if constexpr(hasInternalToJsonFunc){
                std::cout << "calling internal serialize!" << std::endl;
                json& jsonInner = jsonData[HelperFunctions::GetClassNameString<A>()];
                static_cast<A*>(static_cast<MainClass*>(this))->InternalSerialize(jsonInner);
            }
        }
        else {
            if constexpr (has_serialize<A>::value) {
                std::cout << "executing serialize for class " << HelperFunctions::GetClassNameString<A>() << std::endl;
                json& jsonInner = jsonData[HelperFunctions::GetClassNameString<MainClass>()]["traits"][HelperFunctions::GetClassNameString<A>()];
                static_cast<A*>(static_cast<MainClass*>(this))->Serialize(jsonInner);
            }
            else if constexpr(hasInternalToJsonFunc){
                std::cout << "calling internal serialize!" << std::endl;
                json& jsonInner = jsonData[HelperFunctions::GetClassNameString<MainClass>()]["traits"][HelperFunctions::GetClassNameString<A>()];
                static_cast<A*>(static_cast<MainClass*>(this))->InternalSerialize(jsonInner);
            }
        }
    }

    template<typename A>
    void GameObjectDeserializeForOne(const json& jsonData) {
        
        constexpr bool hasInternalFromJsonFunc = requires (const json& j,A& a) {
            a.InternalDeserialize(j);
        };
        

         if constexpr (std::is_same<A,MainClass>::value){
            if constexpr (has_deserialize<A>::value) {
                std::cout << "executing deserialize for class " << HelperFunctions::GetClassNameString<A>() << std::endl;
                if(jsonData.contains(HelperFunctions::GetClassNameString<A>())){
                    const json& jsonInner = jsonData[HelperFunctions::GetClassNameString<A>()];
                    static_cast<A*>(static_cast<MainClass*>(this))->Deserialize(jsonInner);
                }
            }
            else if constexpr(hasInternalFromJsonFunc){
                std::cout << "calling internal deserialize!" << std::endl;
                if(jsonData.contains(HelperFunctions::GetClassNameString<A>())){
                    const json& jsonInner = jsonData[HelperFunctions::GetClassNameString<A>()];
                    static_cast<A*>(static_cast<MainClass*>(this))->InternalDeserialize(jsonInner);
                }
            }
        }
        else {
            if constexpr (has_serialize<A>::value) {
                std::cout << "executing serialize for class " << HelperFunctions::GetClassNameString<A>() << std::endl;
                if(jsonData.contains(HelperFunctions::GetClassNameString<MainClass>()) && jsonData[HelperFunctions::GetClassNameString<MainClass>()].contains("traits")) {
                    if(jsonData[HelperFunctions::GetClassNameString<MainClass>()]["traits"].contains(HelperFunctions::GetClassNameString<A>())){
                        const json& jsonInner = jsonData[HelperFunctions::GetClassNameString<MainClass>()]["traits"][HelperFunctions::GetClassNameString<A>()];
                        static_cast<A*>(static_cast<MainClass*>(this))->Deserialize(jsonInner);
                    }
                }
            }
            else if constexpr(hasInternalFromJsonFunc){
                std::cout << "calling internal serialize!" << std::endl;
                if(jsonData.contains(HelperFunctions::GetClassNameString<MainClass>()) && jsonData[HelperFunctions::GetClassNameString<MainClass>()].contains("traits")) {
                    if(jsonData[HelperFunctions::GetClassNameString<MainClass>()]["traits"].contains(HelperFunctions::GetClassNameString<A>())){
                        const json& jsonInner = jsonData[HelperFunctions::GetClassNameString<MainClass>()]["traits"][HelperFunctions::GetClassNameString<A>()];
                        static_cast<A*>(static_cast<MainClass*>(this))->InternalDeserialize(jsonInner);
                    }
                }
            }
        }
        
        
    }

    void GameObjectSerialize(json& json) override {

        GameObjectSerializeForOne<MainClass>(json);
        (GameObjectSerializeForOne<DerivedClasses>(json),...);
    }

    void GameObjectDeserialize(const json& jsonData) override {

        GameObjectDeserializeForOne<MainClass>(jsonData);
        (GameObjectDeserializeForOne<DerivedClasses>(jsonData),...);
    }

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
        if(GameObject::instantiatedClassesPerType.find(className) == GameObject::instantiatedClassesPerType.end()){
            GameObject::instantiatedClassesPerType[className] = {};
        }
        GameObject::instantiatedClassesPerType[className].push_back(this);

        GameObjectOnCreateForOne<MainClass>();
        (GameObjectOnCreateForOne<DerivedClasses>(),...);
    };


    

    void GameObjectOnDestroy() override {

        GameObject::GameObjectOnDestroy();
        
        GameObjectOnDestroyForOne<MainClass>();
        (GameObjectOnDestroyForOne<DerivedClasses>(),...);

        GameObject::instantiatedClassesPerType[className].erase(std::find(GameObject::instantiatedClassesPerType[className].begin(),GameObject::instantiatedClassesPerType[className].end(),static_cast<GameObject*>(this)));

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