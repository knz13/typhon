#pragma once
#include "general.h"
#include "generic_reflection.h"
#include "game_object.h"
#include "ecs_registry.h"
#include "game_object_traits.h"
#include "keyboard_adaptations.h"
#include "crunch_texture_packer.h"
#include <ranges>



class Engine {
public:
    static void Initialize();
    static void Unload();

    static std::vector<std::string> GetImagePathsFromLibrary();
    static const std::map<std::string,TextureAtlasImageProperties>& GetTextureAtlas();
    static std::string GetPathToAtlas();


    template<typename T>
    static T& CreateNewGameObject() {
        static_assert(std::is_base_of<GameObject,T>::value,"Can only create Game Objects that are derived from GameObject");
        entt::entity e = ECSRegistry::Get().create();
        aliveObjects[e] = std::shared_ptr<GameObject>(new T());
        aliveObjects[e].get()->handle = e;
        aliveObjects[e].get()->GameObjectOnCreate();

        if constexpr (std::is_base_of<OnBeignBaseOfObjectInternal,T>::value) {
            static_cast<OnBeignBaseOfObjectInternal*>(static_cast<T*>(aliveObjects[e].get()))->ExecuteOnObjectCreationInternal(aliveObjects[e].get());
        }

        if constexpr (has_set_defaults_function<T>::value){
            static_cast<T*>(aliveObjects[e].get())->SetDefaults();
        }

        return *static_cast<T*>(aliveObjects[e].get());
    };


    static std::string SerializeCurrent();
    static json SerializeCurrentJSON();
    static bool DeserializeToCurrent(std::string scene);
    static const std::vector<GameObject*>& View(std::string typeName) {
        static std::vector<GameObject*> dummy = std::vector<GameObject*>();
        if(GameObject::instantiatedClassesPerType.find(typeName) != GameObject::instantiatedClassesPerType.end()) {
            return GameObject::instantiatedClassesPerType[typeName];
        }
       
        return dummy;
    }
    template<typename T>
    static const std::vector<T*>& View() {
        static std::vector<T*> dummy = std::vector<T*>();
        std::string typeName = HelperFunctions::GetClassNameString<T>();
        if(GameObject::instantiatedClassesPerType.find(typeName) != GameObject::instantiatedClassesPerType.end()) {
            dummy.clear();
            std::transform(GameObject::instantiatedClassesPerType[typeName].begin(),GameObject::instantiatedClassesPerType[typeName].end(),std::back_inserter(dummy),[](GameObject* obj){ return (static_cast<T*>(obj));});
            return dummy;
        }

        dummy.clear();
        return dummy;
    }

    static GameObject* CreateNewGameObject(int64_t identifier) {
        if(GameObject::GetInstantiableClassesFunctions().find(identifier) == GameObject::GetInstantiableClassesFunctions().end()){
            return nullptr;
        }
        else {
            auto [e,ptr] = GameObject::GetInstantiableClassesFunctions().at(identifier)();
            aliveObjects[e] = ptr;
            return ptr.get();
        }
    }
    static GameObject* CreateNewGameObject(std::string className) {
        if(GameObject::instantiableClassesIDs.find(className) == GameObject::instantiableClassesIDs.end()){
            return nullptr;
        }
        int64_t identifier = GameObject::instantiableClassesIDs[className];
        auto [e,ptr] = GameObject::GetInstantiableClassesFunctions().at(identifier)();
        aliveObjects[e] = ptr;
        return ptr.get();
    }

    static bool HasInitialized() {
        return isInitialized;
    }
   

    static bool RemoveGameObject(GameObject obj) {
        if(!obj.Valid()){
            std::cout << "Could not remove gameobject, invalid id!" << std::endl;
            return false;
        }
        
        aliveObjects[obj.Handle()]->GameObjectOnDestroy();

        aliveObjects.erase(obj.handle);
        ECSRegistry::Get().destroy(obj.handle);
        return true;
    }

    static bool RemoveGameObject(entt::entity e) {
        if(aliveObjects.find(e) == aliveObjects.end()){
            std::cout << "Could not remove gameobject, invalid id!" << std::endl;
            return false;
        }
        aliveObjects[e]->GameObjectOnDestroy();
        aliveObjects.erase(e);
        ECSRegistry::Get().destroy(e);
        return true;
    }

    static int64_t AliveObjects() {
        return aliveObjects.size();
    };

    static void Update(double dt);

    static const Vector2f& GetMousePosition() {
        return mousePosition;
    }
    
    static void PushKeyDown(int64_t key);
    static void PushKeyUp(int64_t key);

    static bool IsKeyPressed(Keys::Key key);
private:
    static bool isInitialized;
    static std::map<std::string,TextureAtlasImageProperties> CreateTextureAtlasFromImages();
    static std::map<std::string,TextureAtlasImageProperties> textureAtlas;
    static std::bitset<std::size(Keys::IndicesOfKeys)> keysPressed;
    static std::unordered_map<entt::entity,std::shared_ptr<GameObject>> aliveObjects;
    static Vector2f mousePosition;


    friend class GameObject;
    friend class EngineInternals;
};


class EngineInternals {
public:
    static std::function<void(double,double,int64_t,int64_t,int64_t,int64_t,double,double,double,double)> enqueueRenderFunc;

    static void SetMousePosition(Vector2f mousePos) {
        Engine::mousePosition = mousePos;
    }
};