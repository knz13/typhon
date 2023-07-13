#pragma once
#include "../general.h"
#include "../generic_reflection.h"
#include "../ecs_registry.h"


class Object {
public:
    bool operator==(const Object&) const = default;

    
    //includes self
    void ExecuteForEveryChildInTree(std::function<void(Object&)> func) {
        for(auto& id : Storage().children){
            Object(id).ExecuteForEveryChildInTree(func);
        }
    }

    void ForEachComponent(std::function<void(Component&)> func){
        if(!Valid()){
            return;
        }
        for(auto [name,storage] : ECSRegistry::Get().storage()){
            if(storage.contains(ID()) && storage.type() != entt::type_id<ObjectStorage>()){
                func(*((Component*)storage.get(ID())));
            }

        }
    }

    void Clear() {
        EraseAllComponents();
        RemoveFromParent();
        RemoveChildren();
    };

    void Serialize(json& val) {
        val["name"] = Storage().name;
        val["id"] = static_cast<int64_t>(handle);
        val["components"] = json::array();
        val["children"] = json::array();
        ForEachComponent([&](Component& comp){
            val["components"].push_back(json::object());
            auto& compJSON = val["components"].back();
            comp.InternalSerialize(compJSON);
        });
        val["children"] = json::array();
        ExecuteForEveryChildInTree([&](Object& obj){
            val["children"].push_back(json::object());
            auto& childJSON = val["children"].back();
            obj.Serialize(childJSON);
        });
    }

    void Deserialize(const json& val);

    

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
        if(e.Valid()){
            e.Storage().children.push_back(ID());
        }
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
            Object(*pos).Storage().parent = ObjectHandle();
            Storage().children.erase(pos);
        }
    }

	void RemoveChildren() {
        auto it = Storage().children.begin();
        while(it != Storage().children.end()){
            Object(*it).Storage().parent = ObjectHandle();
            Storage().children.erase(it);
            it = Storage().children.begin();
        }
	}

	void AddChild(Object e) {
        auto pos =std::find(Storage().children.begin(),Storage().children.end(),e.ID());
		if (pos == Storage().children.end()) {
			Storage().children.push_back(e.ID());
            e.Storage().parent = this->ID();
		}
	}

    size_t NumberOfChildren() {
        return Storage().children.size();
    }

    template<typename T>
    T* GetComponent() {
        return ECSRegistry::GetComponentFromEntity<T>(handle);
    }

    template<typename T,typename ...Args>
    bool AddComponent(Args&&... args){
        return ECSRegistry::AddComponentToEntity<T>(handle,std::forward<Args>(args)...);
    }
    
    template<typename T>
    bool EraseComponent(){
        return ECSRegistry::EraseComponentFromEntity<T>(handle);
    }

    void EraseAllComponents(){
        for(auto [name,storage] : ECSRegistry::Get().storage()){
            if(storage.contains(ID())){
                ((Component*)storage.get(ID()))->InternalDestroy();
            }
        }
    }

    std::string Name() {
        if(Valid()){
            return Storage().name;
        }
        return "Invalid Entity";
    }

    void SetName(std::string name) {
        if(Valid()){
            Storage().name = name;
        }
    }


    template<typename... Components>
    bool HasAllOf(){
        return ECSRegistry::Get().all_of<Components...>(handle);
    }

    template<typename... Components>
    bool HasAnyOf(){
        return ECSRegistry::Get().any_of<Components...>(handle);
    }

    template<typename T>
    bool HasComponent(){
        return ECSRegistry::Get().any_of<T>(handle);
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
        if(!Valid()){
            throw;
        }
        return ECSRegistry::Get().get_or_emplace<ObjectStorage>(handle);
    }
    
    entt::entity handle;



};