#pragma once
#include "general.h"
#include "generic_reflection.h"
#include "ecs_registry.h"
#include "keyboard_adaptations.h"
#include "crunch_texture_packer.h"
#include "object/object.h"
#include <ranges>
#include "component/make_component.h"

class Engine;
class EngineInternals
{
public:
    static std::function<void(double, double, int64_t, int64_t, int64_t, int64_t, double, double, double, double)> enqueueRenderFunc;
    static std::function<void()> onChildrenChangedFunc;

    static void SetMousePosition(Vector2f mousePos);

    static void PushKeyDown(int64_t key);
    static void PushKeyUp(int64_t key);

private:
    static std::bitset<std::size(Keys::IndicesOfKeys)> keysPressed;

    friend class Engine;
};

class Engine
{
public:
    static void Initialize();
    static void Unload();

    static std::vector<std::string> GetImagePathsFromLibrary();
    static const std::map<std::string, TextureAtlasImageProperties> &GetTextureAtlas();
    static std::string GetPathToAtlas();

    static entt::entity IDFromHandle(int64_t handle)
    {
        return entt::entity{static_cast<std::underlying_type_t<entt::entity>>(handle)};
    };

    static void View(std::function<void(Typhon::Object)> viewFunc)
    {
        return Typhon::ECSRegistry::Get().each([=](entt::entity e)
                                               { viewFunc(Typhon::Object(e)); });
    }

    template <typename T>
    static void View(std::function<void(Typhon::Object)> viewFunc)
    {
        for (auto entity : Typhon::ECSRegistry::Get().view<T>())
        {
            viewFunc(Typhon::Object(entity));
        }
    }

    static void View(entt::id_type typeID, std::function<void(Typhon::Object)> viewFunc)
    {
        auto storage = Typhon::ECSRegistry::Get().storage(typeID);
        if (storage == nullptr)
        {
            return;
        }
        for (auto it = storage->begin(); it != storage->end(); it++)
        {
            viewFunc(Typhon::Object(*it));
        }
    }

    static int64_t NumberAlive()
    {
        return Typhon::ECSRegistry::Get().alive();
    }

    static Typhon::Object GetObjectFromID(int64_t id)
    {
        entt::entity objID{static_cast<std::underlying_type_t<entt::entity>>(id)};

        if (Typhon::ECSRegistry::ValidateEntity(objID))
        {
            return Typhon::Object(objID);
        }
        else
        {
            return {};
        }
    }

    static bool RemoveObject(int64_t id)
    {
        entt::entity objID{static_cast<std::underlying_type_t<entt::entity>>(id)};
        if (!ValidateHandle(id))
        {
            return false;
        }
        std::vector<entt::entity> ids{objID};
        Typhon::Object(objID).ExecuteForEveryChildInTree([&](Typhon::Object &obj)
                                                         { ids.push_back(obj.ID()); });

        for (auto entity : ids)
        {
            if (Typhon::ECSRegistry::ValidateEntity(entity))
            {
                Typhon::Object(entity).Clear();
                Typhon::ECSRegistry::DeleteObject(entity);
            }
        }

        EngineInternals::onChildrenChangedFunc();
        return true;
    }

    static Typhon::Object CreateObject(std::string name = "");

    static std::string SerializeCurrent();
    static json SerializeCurrentJSON();

    static bool ValidateHandle(int64_t handle)
    {
        return Typhon::ECSRegistry::ValidateEntity(entt::entity{static_cast<std::underlying_type_t<entt::entity>>(handle)});
    }

    static void Clear()
    {
        Typhon::ECSRegistry::Get().each([](entt::entity e)
                                        {
            if(Typhon::ECSRegistry::ValidateEntity(e)){
                Typhon::Object(e).ForEachComponent([](Typhon::Component& comp){
                    comp.InternalDestroy();
                });
            } });

        Typhon::ECSRegistry::Clear();
    };

    static bool DeserializeToCurrent(std::string scene);

    static bool HasInitialized()
    {
        return isInitialized;
    }

    static void Update(double dt);

    static const Vector2f &GetMousePosition()
    {
        return mousePosition;
    }

    static bool IsKeyPressed(Keys::Key key);

private:
    static bool isInitialized;
    static std::map<std::string, TextureAtlasImageProperties> CreateTextureAtlasFromImages();
    static std::map<std::string, TextureAtlasImageProperties> textureAtlas;
    static Vector2f mousePosition;

    friend class EngineInternals;
};
