#pragma once
#include "general.h"
#include "generic_reflection.h"
#include "game_object.h"
#include "ecs_registry.h"
#include "game_object_traits.h"
#include "keyboard_adaptations.h"
#include "crunch_texture_packer.h"
#include "object/object.h"
#include <ranges>
#include "shader_compiler.h"

class Engine;
class EngineInternals {
public:
    static std::function<void(double,double,int64_t,int64_t,int64_t,int64_t,double,double,double,double)> enqueueRenderFunc;
    static std::function<void()> onChildrenChangedFunc;

    static void SetMousePosition(Vector2f mousePos);

    static void PushKeyDown(int64_t key);
    static void PushKeyUp(int64_t key);
private:
    static std::bitset<std::size(Keys::IndicesOfKeys)> keysPressed;

    friend class Engine;
    
};

class Engine {
public:
    static void Initialize();
    static void Unload();

    static std::vector<std::string> GetImagePathsFromLibrary();
    static const std::map<std::string,TextureAtlasImageProperties>& GetTextureAtlas();
    static std::string GetPathToAtlas();

    static void View(std::function<void(Object)> viewFunc) {
        return ECSRegistry::Get().each([=](entt::entity e){
            viewFunc(Object(e));
        });
    }

    static int64_t NumberAlive() {
        return ECSRegistry::Get().alive();
    }
    

    static Object GetObjectFromID(int64_t id) {
        entt::entity objID{static_cast<std::underlying_type_t<entt::entity>>(id)};

        if(ECSRegistry::ValidateEntity(objID)){
            return Object(objID);
        }
        else {
            return {};
        }
    }


    static bool RemoveObject(int64_t id) {
        entt::entity objID{static_cast<std::underlying_type_t<entt::entity>>(id)};

        if(ECSRegistry::DeleteObject(objID)){
            EngineInternals::onChildrenChangedFunc();
            return true;
        }
        else {
            return false;
        }
    }

    static Object CreateObject(std::string name = "") {
        Object obj{ECSRegistry::CreateEntity()};
        if(name != ""){
            obj.SetName(name);
            EngineInternals::onChildrenChangedFunc();
            return obj;
        }
        EngineInternals::onChildrenChangedFunc();
        return {ECSRegistry::CreateEntity()};
    }
    


    static std::string SerializeCurrent();
    static json SerializeCurrentJSON();

    static bool ValidateHandle(int64_t handle) {
        return ECSRegistry::ValidateEntity(entt::entity{static_cast<std::underlying_type_t<entt::entity>>(handle)});
    }

    static void Clear() {
        ECSRegistry::Get().each([](entt::entity e){
            if(ECSRegistry::ValidateEntity(e)){
                Object(e).ForEachComponent([](Component& comp){
                    comp.Destroy();
                });
            }
        });

        ECSRegistry::Clear();
    };

    static bool DeserializeToCurrent(std::string scene);


    static bool HasInitialized() {
        return isInitialized;
    }
        
    static void Update(double dt);

    static const Vector2f& GetMousePosition() {
        return mousePosition;
    }

    static bool IsKeyPressed(Keys::Key key);
private:
    static bool isInitialized;
    static std::map<std::string,TextureAtlasImageProperties> CreateTextureAtlasFromImages();
    static std::map<std::string,TextureAtlasImageProperties> textureAtlas;
    static std::unordered_map<int64_t,std::shared_ptr<GameObject>> aliveObjects;
    static Vector2f mousePosition;


    friend class GameObject;
    friend class EngineInternals;
};


