#pragma once
#include "../general.h"
#include "../ecs_registry.h"

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

    UIBuilder BuildEditorUI() override {
        return (CallBuildEditorUIForOne<T>());
    }

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
    UIBuilder CallBuildEditorUIForOne() {
        if constexpr (has_build_editor_ui<A>::value) {
            return static_cast<A*>(this)->BuildEditorUI();
        }
        return UIBuilder();
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