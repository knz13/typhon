#pragma once
#include "general.h"
#include "generic_reflection.h"
#include "game_object.h"
#include "ecs_registry.h"
#include "game_object_traits.h"
#include "keyboard_adaptations.h"

class Engine {
public:
    static void Initialize();
    

    static std::vector<std::string> GetImagePathsFromLibrary();
    static std::string GetPathToAtlas();


    template<typename T>
    static T& CreateNewGameObject() {
        static_assert(std::is_base_of<GameObject,T>::value,"Can only create Game Objects that are derived from GameObject");
        std::cout << "Trying to create game object with type " << HelperFunctions::GetClassNameString<T>()<<std::endl;
        entt::entity e = ECSRegistry::Get().create();
        aliveObjects[e] = std::shared_ptr<GameObject>(new T());
        aliveObjects[e].get()->handle = e;
        aliveObjects[e].get()->GameObjectOnCreate();

        if constexpr (std::is_base_of<OnBeignBaseOfObjectInternal,T>::value) {
            static_cast<OnBeignBaseOfObjectInternal*>(static_cast<T*>(aliveObjects[e].get()))->ExecuteOnObjectCreationInternal(aliveObjects[e].get());
        }

        return *static_cast<T*>(aliveObjects[e].get());
    };

   

    static bool RemoveGameObject(GameObject obj) {
        if(!obj.Valid()){
            std::cout << "Could not remove gameobject, invalid id!" << std::endl;
            return false;
        }
        

        aliveObjects.erase(obj.handle);
        ECSRegistry::Get().destroy(obj.handle);
        return true;
    }

    static bool RemoveGameObjectFromHandle(entt::entity e) {
        if(aliveObjects.find(e) == aliveObjects.end()){
            std::cout << "Could not remove gameobject, invalid id!" << std::endl;
            return false;
        }
        aliveObjects.erase(e);
        ECSRegistry::Get().destroy(e);
        return true;
    }

    static void Update(double dt);

    static const Vector2f& GetMousePosition() {
        return mousePosition;
    }
    
    static void PushKeyDown(int64_t key);
    static void PushKeyUp(int64_t key);

    static bool IsKeyPressed(InputKey key);
private:
    static void CreateTextureAtlasFromImages();

    static std::bitset<std::size(Keys::IndicesOfKeys)> keysPressed;
    static std::unordered_map<entt::entity,std::shared_ptr<GameObject>> aliveObjects;
    static Vector2f mousePosition;


    friend class GameObject;
    friend class EngineInternals;
};


class EngineInternals {
public:
    static void SetMousePosition(Vector2f mousePos) {
        Engine::mousePosition = mousePos;
    }
};