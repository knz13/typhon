#pragma once
#include "general.h"
#include "generic_reflection.h"
#include "game_object.h"
#include "ecs_registry.h"
#include "game_object_traits.h"
#include "keyboard_adaptations.h"
#include "crunch_texture_packer.h"
#include "object.h"
#include <ranges>
#include "shader_compiler.h"

class EngineInternals {
public:
    static std::function<void(double,double,int64_t,int64_t,int64_t,int64_t,double,double,double,double)> enqueueRenderFunc;
    static std::function<void()> onChildrenChangedFunc;

    static void SetMousePosition(Vector2f mousePos);
};

class Engine {
public:
    static void Initialize();
    static void Unload();

    static std::vector<std::string> GetImagePathsFromLibrary();
    static const std::map<std::string,TextureAtlasImageProperties>& GetTextureAtlas();
    static std::string GetPathToAtlas();


    static GameObject* GetObjectFromID(int64_t id) {
        if(!Engine::ValidateHandle(id)){
            return nullptr;
        }

        return aliveObjects[id].get();
    };

    static Object CreateNewObject() {
        return Object(ECSRegistry::CreateEntity());
    }

    


    template<typename T>
    static T& CreateNewGameObject(std::string name = "") {
        static_assert(std::is_base_of<GameObject,T>::value,"Can only create Game Objects that are derived from GameObject");
        int64_t e = Random::get<int64_t>();
        aliveObjects[e] = std::shared_ptr<GameObject>(new T());
        if(name == ""){
            aliveObjects[e].get()->name = HelperFunctions::GetClassNameString<T>();
        }
        else {
            aliveObjects[e].get()-> name = name;
        }
        aliveObjects[e].get()->handle = e;
        aliveObjects[e].get()->GameObjectOnCreate();

        if constexpr (std::is_base_of<OnBeignBaseOfObjectInternal,T>::value) {
            static_cast<OnBeignBaseOfObjectInternal*>(static_cast<T*>(aliveObjects[e].get()))->ExecuteOnObjectCreationInternal(aliveObjects[e].get());
        }

        if constexpr (has_set_defaults_function<T>::value){
            static_cast<T*>(aliveObjects[e].get())->SetDefaults();
        }
        EngineInternals::onChildrenChangedFunc();
        return *static_cast<T*>(aliveObjects[e].get());
    };


    static std::string SerializeCurrent();
    static json SerializeCurrentJSON();

    static bool ValidateHandle(int64_t handle) {
        return aliveObjects.find(handle) != aliveObjects.end();
    }

    static void Clear() {
        auto iter = aliveObjects.begin();
        while(iter != aliveObjects.end()){
            const auto& [key,value] = *iter;
            RemoveGameObject(key);
            iter = aliveObjects.begin();
        }

        ECSRegistry::Clear();
    };

    static bool DeserializeToCurrent(std::string scene);


    static const std::vector<GameObject*>& View() {
        static std::vector<GameObject*> dummy = std::vector<GameObject*>();
        dummy.clear();

        dummy.reserve(aliveObjects.size());
        for(const auto& [key,val] : aliveObjects){
            dummy.push_back(val.get());
        }

        return dummy;

    }

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

    static GameObject* CreateNewGameObject(int64_t identifier,std::string name = "") {
        if(GameObject::GetInstantiableClassesFunctions().find(identifier) == GameObject::GetInstantiableClassesFunctions().end()){
            return nullptr;
        }
        else {
            auto [e,ptr] = GameObject::GetInstantiableClassesFunctions().at(identifier)();
            aliveObjects[e] = ptr;
            if(name == ""){
                aliveObjects[e].get()->name = GameObject::instantiableClassesNames[identifier];
            }
            else {
                aliveObjects[e].get()-> name = name;
            }
            EngineInternals::onChildrenChangedFunc();
            return ptr.get();
        }
    }
    static GameObject* CreateNewGameObject(std::string className,std::string name = "") {
        if(GameObject::instantiableClassesIDs.find(className) == GameObject::instantiableClassesIDs.end()){
            return nullptr;
        }
        int64_t identifier = GameObject::instantiableClassesIDs[className];
        auto [e,ptr] = GameObject::GetInstantiableClassesFunctions().at(identifier)();
        aliveObjects[e] = ptr;
        if(name == ""){
            aliveObjects[e].get()->name = GameObject::instantiableClassesNames[GameObject::instantiableClassesIDs[className]];
        }
        else {
            aliveObjects[e].get()-> name = name;
        }
        EngineInternals::onChildrenChangedFunc();
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
        EngineInternals::onChildrenChangedFunc();
        return true;
    }

    static bool RemoveGameObject(int64_t e) {
        if(aliveObjects.find(e) == aliveObjects.end()){
            std::cout << "Could not remove gameobject, invalid id!" << std::endl;
            return false;
        }
        aliveObjects[e]->GameObjectOnDestroy();
        aliveObjects.erase(e);
        EngineInternals::onChildrenChangedFunc();
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
    static std::unordered_map<int64_t,std::shared_ptr<GameObject>> aliveObjects;
    static Vector2f mousePosition;


    friend class GameObject;
    friend class EngineInternals;
};

