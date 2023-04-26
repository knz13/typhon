#pragma once
#include "general.h"
#include "generic_reflection.h"

#include "ecs_registry.h"

DEFINE_HAS_SIGNATURE(has_on_create,T::Create,void (T::*) ());
DEFINE_HAS_SIGNATURE(has_on_destroy,T::Destroy,void (T::*) ());
DEFINE_HAS_SIGNATURE(has_serialize,T::Serialize,void (T::*) (json&));
DEFINE_HAS_SIGNATURE(has_deserialize,T::Deserialize,void (T::*) (const json&));
DEFINE_HAS_SIGNATURE(has_update,T::Update,void (T::*) (double));
DEFINE_HAS_SIGNATURE(has_title_on_editor_function,T::TitleOnEditor,std::string (*)());


template<typename... DerivedClasses>
class MakeComponent;

class Component {
public:

    virtual void Update(double dt){};

    virtual void Create() {};

    virtual void Destroy() {};

    virtual void Serialize(json& json) {};

    virtual void Deserialize(const json& json) {};

private:
    std::string componentName = "";
    entt::id_type typeID = -1;

    friend class Object;
    template<typename...>
    friend class MakeComponent;
};

template<typename... DerivedClasses>
class MakeComponent : public Component{
public:
    MakeComponent() {
        componentName = HelperFunctions::GetClassNameString<NthTypeOf<Reflection::IndexOfTopClass<DerivedClasses...>(),DerivedClasses...>>();
        typeID = entt::type_id<NthTypeOf<Reflection::IndexOfTopClass<DerivedClasses...>(),DerivedClasses...>>().hash();
    }

    void Update(double dt) override {
        (CallUpdateForOne<DerivedClasses>(dt),...);
    };

    void Create() override {
        (CallCreateForOne<DerivedClasses>(),...);
    };
    
    void Destroy() override {
        (CallDestroyForOne<DerivedClasses>(),...);
    };
    
    void Serialize(json& jsonData) override {
        (CallSerializeForOne<DerivedClasses>(jsonData),...);
    };
    
    void Deserialize(const json& jsonData) override {
        (CallDeserializeForOne<DerivedClasses>(jsonData),...);
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

};



class Object {
public:
    //includes self
    void ExecuteForEveryChildInTree(std::function<void(Object&)> func) {
        func(*this);
        for(auto& id : Storage().children){
            Object(id).ExecuteForEveryChildInTree(func);
        }
    }

    void ForEachComponent(std::function<void(Component&)> func){
        if(!Valid()){
            return;
        }
        for(auto [name,storage] : ECSRegistry::Get().storage()){
            if(storage.contains(ID())){
                func(*((Component*)storage.get(ID())));
            }
        }
    }

    bool IsChildOf(Object e) {
        return Storage().parent.ID() == e.ID();
    }

    bool IsMyChild(Object e){
        return std::find(Storage().children.begin(),Storage().children.end(),e.ID()) != Storage().children.end();
    }
    
    bool HasParent() {
        return Storage().parent.GetAsObject().Valid();
    }

    void SetParent(Object e) {
        Storage().parent = e.ID();
	}

    void RemoveFromParent() {
        if(Storage().parent){
            auto& children = Storage().parent.GetAsObject().Storage().children;
            children.erase(std::find(children.begin(),children.end(),ID()));
        }
        Storage().parent = ObjectHandle();
    }

    void RemoveChild(Object e) {
        auto pos = std::find(Storage().children.begin(),Storage().children.end(),e.ID());
        if(pos != Storage().children.end()){
            Object(*pos).RemoveFromParent();
        }
    }

	void RemoveChildren() {
        auto it = Storage().children.begin();
        while(it != Storage().children.end()){
            Object(*it).RemoveFromParent();
            it = Storage().children.begin();
        }
	}

	void AddChild(Object e) {
        auto pos =std::find(Storage().children.begin(),Storage().children.end(),e.ID());
		if (pos == Storage().children.end()) {
			Storage().children.push_back(e.ID());
            e.SetParent(*this);
		}
	}

    size_t NumberOfChildren() {
        return Storage().children.size();
    }

    template<typename T>
    T* GetComponent() {
        if(!Valid()){
            return nullptr;
        }
        if(!HasAnyOf<T>()){
            return nullptr;
        }

        return &ECSRegistry::Get().get<T>(handle);
    }

    template<typename T,typename ...Args>
    bool AddComponent(Args&&... args){
        static_assert(std::is_base_of<MakeComponent<T>,T>::value,"This class is not derived from MakeComponent, therefore it cannot be used as a component");
        if(!Valid()){
            return false;
        }
        if(HasAnyOf<T>()){
            return true;
        }

        ECSRegistry::Get().emplace_or_replace<T>(handle, std::forward<Args>(args)...);

        return true;
    }
    
    template<typename T>
    bool EraseComponent(){
         static_assert(std::is_base_of<MakeComponent<T>,T>::value,"This class is not derived from MakeComponent, therefore it couldn't even be added as a component");
        if(!Valid()){
            return false;
        }
        if(!HasAnyOf<T>()){
            return false;
        }

        ECSRegistry::Get().erase<T>(ID());
        
        return true;
    }

    template<typename... Components>
    bool HasAllOf(){
        return ECSRegistry::Get().all_of<Components...>(handle);
    }

    template<typename... Components>
    bool HasAnyOf(){
        return ECSRegistry::Get().any_of<Components...>(handle);
    }

    const std::vector<std::string>& GetComponentsNames() {
        return Storage().componentNames;
    }

    bool Valid() {

        return ECSRegistry::Get().valid(handle);
    }

    entt::entity ID() {
        return handle;
    }

    Object(entt::entity e) : handle(e) {
    }

    Object() : handle() {}

private:

    ObjectStorage& Storage() {
        return ECSRegistry::Get().get_or_emplace<ObjectStorage>(handle);
    }
    
    entt::entity handle;



};