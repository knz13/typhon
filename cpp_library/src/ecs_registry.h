#pragma once
#include "general.h"
#include "component.h"

class Object;
class ObjectHandle {
public:
    ObjectHandle(entt::entity e) : handle(e) {};

    ObjectHandle() {};

    Object GetAsObject();

    entt::entity ID() {
        return handle;
    }

    operator bool() const;

private:
    entt::entity handle = entt::null;
};

class ObjectStorage { 
private:

    std::vector<std::string> componentNames = {};
    ObjectHandle parent = {};
    ObjectHandle master = {};
    std::vector<entt::entity> children = {};
    

    friend class ECSRegistry;
    friend class Object;
};
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
        static_cast<Component*>(&obj)->Create();
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
        
        static_cast<Component*>(GetComponentFromEntity<T>(e))->Destroy();

        return true;
    }

    

private:
    static entt::registry registry;

    template<typename>
    friend class MakeComponent;
};


template<typename T>
class MakeComponent : public Component,public Reflection::IsInitializedStatically<MakeComponent<T>>{
private:
    static inline std::string staticComponentName = HelperFunctions::GetClassNameString<T>();
    static inline entt::id_type staticTypeID = entt::type_id<T>().hash();

public:

    static void InitializeStatically() {
        std::cout << "initializing statically for " << HelperFunctions::GetClassNameString<T>() << std::endl;
        AddToECSRegistryIDsMap<T>();
    }

    MakeComponent() {
        componentName = staticComponentName;
        typeID = staticTypeID;
    }

    void Update(double dt) override {
        (CallUpdateForOne<T>(dt));
    };

    void Create() override {
        (CallCreateForOne<T>());

    };
    
    void Destroy() override {
        (CallDestroyForOne<T>());
        Component::Destroy();
    };
    
    void Serialize(json& jsonData) override {
        (CallSerializeForOne<T>(jsonData));
    };
    
    void Deserialize(const json& jsonData) override {
        (CallDeserializeForOne<T>(jsonData));
    };

private:
    template<typename A>
    void CallUpdateForOne(double dt) {
        if constexpr (has_update<A>::value){
            static_cast<A*>(this)->Update(dt);
        }
    }
    template<typename A>
    void CallCreateForOne() {
        if constexpr (has_on_create<A>::value){
            static_cast<A*>(this)->Create();
        }
    }
    template<typename A>
    void CallDestroyForOne() {
        if constexpr (has_on_destroy<A>::value){
            static_cast<A*>(this)->Destroy();
        }
    }
    template<typename A>
    void CallSerializeForOne(json& jsonData) {
        constexpr bool hasInternalToJsonFunc = requires (json& j,A& a) {
            a.InternalSerialize(j);
        };
        if constexpr (has_serialize<A>::value) {
            std::cout << "executing serialize for class " << HelperFunctions::GetClassNameString<A>() << std::endl;
            json& jsonInner = jsonData[HelperFunctions::GetClassNameString<A>()]["traits"][HelperFunctions::GetClassNameString<A>()];
            if constexpr (has_title_on_editor_function<A>::value) {
                jsonData[HelperFunctions::GetClassNameString<A>()]["editor_titles"][HelperFunctions::GetClassNameString<A>()] = A::TitleOnEditor();
            }
            else {
                jsonData[HelperFunctions::GetClassNameString<A>()]["editor_titles"][HelperFunctions::GetClassNameString<A>()] = HelperFunctions::GetClassNameString<A>();
            }
            static_cast<A*>(this)->Serialize(jsonInner);
        }
        else if constexpr(hasInternalToJsonFunc){
            std::cout << "calling internal serialize!" << std::endl;
            json& jsonInner = jsonData[HelperFunctions::GetClassNameString<A>()]["traits"][HelperFunctions::GetClassNameString<A>()];
            static_cast<A*>(this)->InternalSerialize(jsonInner);
        }
    }
    template<typename A>
    void CallDeserializeForOne(const json& jsonData) {

        constexpr bool hasInternalFromJsonFunc = requires (const json& j,A& a) {
            a.InternalDeserialize(j);
        };
        if constexpr (has_serialize<A>::value) {
            std::cout << "executing serialize for class " << HelperFunctions::GetClassNameString<A>() << std::endl;
            if(jsonData.contains(HelperFunctions::GetClassNameString<A>()) && jsonData[HelperFunctions::GetClassNameString<A>()].contains("traits")) {
                if(jsonData[HelperFunctions::GetClassNameString<A>()]["traits"].contains(HelperFunctions::GetClassNameString<A>())){
                    const json& jsonInner = jsonData[HelperFunctions::GetClassNameString<A>()]["traits"][HelperFunctions::GetClassNameString<A>()];
                    static_cast<A*>(this)->Deserialize(jsonInner);
                }
            }
        }
        else if constexpr(hasInternalFromJsonFunc){
            std::cout << "calling internal serialize!" << std::endl;
            if(jsonData.contains(HelperFunctions::GetClassNameString<A>()) && jsonData[HelperFunctions::GetClassNameString<A>()].contains("traits")) {
                if(jsonData[HelperFunctions::GetClassNameString<A>()]["traits"].contains(HelperFunctions::GetClassNameString<A>())){
                    const json& jsonInner = jsonData[HelperFunctions::GetClassNameString<A>()]["traits"][HelperFunctions::GetClassNameString<A>()];
                    static_cast<A*>(this)->InternalDeserialize(jsonInner);
                }
            }
        }
    }

    

    template<typename A>
    static void AddToECSRegistryIDsMap() {
        entt::meta<A>().type(entt::hashed_string(staticComponentName.c_str()));
        entt::meta<A>().template data<&MakeComponent<T>::staticTypeID>(entt::hashed_string(std::string(staticComponentName + "_type_id").c_str()));
        entt::meta<A>().template func<&ECSRegistry::AddComponentToEntity<A>>(entt::hashed_string(std::string("AddComponent").c_str()));
        entt::meta<A>().template func<&ECSRegistry::EraseComponentFromEntity<A>>(entt::hashed_string(std::string("EraseComponent").c_str()));
        entt::meta<A>().template func<&ECSRegistry::GetComponentFromEntity<A>>(entt::hashed_string(std::string("GetComponent").c_str()));
    }

};
