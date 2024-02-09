#pragma once
#include "../general.h"
#include "../ecs_registry.h"
namespace Typhon
{

    namespace ComponentInternals
    {
        class ComponentStatics
        {
        public:
            static std::vector<entt::id_type> componentTypes;
            static std::map<std::string, int64_t> defaultComponentMenuMap;
        };

        std::string GetDefaultComponentsJSON();

    }
    template <typename T>
    class MakeComponent : public Component, public Reflection::IsInitializedStatically<MakeComponent<T>>
    {
    private:
        static inline std::string staticComponentName = HelperFunctions::GetClassNameString<T>();
        static inline entt::id_type staticTypeID = entt::type_id<T>().hash();

    public:
        static void InitializeStatically()
        {
            ComponentInternals::ComponentStatics::componentTypes.push_back(staticTypeID);
            AddToECSRegistryIDsMap<T>();
        }

        MakeComponent()
        {
            componentName = staticComponentName;
            typeID = staticTypeID;
        }

        void InternalUpdate(double dt)
        {
            (InternalUpdateForOne<T>(dt));
        };

        void InternalCreate()
        {
            (InternalCreateForOne<T>());
        };

        void InternalDestroy()
        {
            (InternalDestroyForOne<T>());
            Typhon::Component::InternalDestroy();
        };

        void InternalSerialize(json &jsonData)
        {
            (InternalSerializeForOne<T>(jsonData));
        };

        void InternalDeserialize(const json &jsonData)
        {
            (InternalDeserializeForOne<T>(jsonData));
        };

        UIBuilder InternalBuildEditorUI()
        {
            return (InternalBuildEditorUIForOne<T>());
        }

    private:
        template <typename A>
        void InternalUpdateForOne(double dt)
        {
            if constexpr (has_update<A>::value)
            {
                static_cast<A *>(this)->Update(dt);
            }
        }
        template <typename A>
        void InternalCreateForOne()
        {
            if constexpr (has_on_create<A>::value)
            {
                static_cast<A *>(this)->Create();
            }
        }
        template <typename A>
        void InternalDestroyForOne()
        {
            if constexpr (has_on_destroy<A>::value)
            {
                static_cast<A *>(this)->Destroy();
            }
        }
        template <typename A>
        void InternalSerializeForOne(json &jsonData)
        {
            constexpr bool hasInternalToJsonFunc = requires(json &j, A &a) {
                a.InternalSerialize(j);
            };
            if constexpr (has_serialize<A>::value)
            {
                std::cout << "executing serialize for class " << HelperFunctions::GetClassNameString<A>() << std::endl;
                json &jsonInner = jsonData[HelperFunctions::GetClassNameString<A>()]["traits"][HelperFunctions::GetClassNameString<A>()];
                if constexpr (has_title_on_editor_function<A>::value)
                {
                    jsonData[HelperFunctions::GetClassNameString<A>()]["editor_titles"][HelperFunctions::GetClassNameString<A>()] = A::TitleOnEditor();
                }
                else
                {
                    jsonData[HelperFunctions::GetClassNameString<A>()]["editor_titles"][HelperFunctions::GetClassNameString<A>()] = HelperFunctions::GetClassNameString<A>();
                }
                static_cast<A *>(this)->Serialize(jsonInner);
            }
            else if constexpr (hasInternalToJsonFunc)
            {
                std::cout << "calling internal serialize!" << std::endl;
                json &jsonInner = jsonData[HelperFunctions::GetClassNameString<A>()]["traits"][HelperFunctions::GetClassNameString<A>()];
                static_cast<A *>(this)->InternalSerialize(jsonInner);
            }
        }
        template <typename A>
        void InternalDeserializeForOne(const json &jsonData)
        {

            constexpr bool hasInternalFromJsonFunc = requires(const json &j, A &a) {
                a.InternalDeserialize(j);
            };
            if constexpr (has_serialize<A>::value)
            {
                std::cout << "executing serialize for class " << HelperFunctions::GetClassNameString<A>() << std::endl;
                if (jsonData.contains(HelperFunctions::GetClassNameString<A>()) && jsonData[HelperFunctions::GetClassNameString<A>()].contains("traits"))
                {
                    if (jsonData[HelperFunctions::GetClassNameString<A>()]["traits"].contains(HelperFunctions::GetClassNameString<A>()))
                    {
                        const json &jsonInner = jsonData[HelperFunctions::GetClassNameString<A>()]["traits"][HelperFunctions::GetClassNameString<A>()];
                        static_cast<A *>(this)->Deserialize(jsonInner);
                    }
                }
            }
            else if constexpr (hasInternalFromJsonFunc)
            {
                std::cout << "calling internal serialize!" << std::endl;
                if (jsonData.contains(HelperFunctions::GetClassNameString<A>()) && jsonData[HelperFunctions::GetClassNameString<A>()].contains("traits"))
                {
                    if (jsonData[HelperFunctions::GetClassNameString<A>()]["traits"].contains(HelperFunctions::GetClassNameString<A>()))
                    {
                        const json &jsonInner = jsonData[HelperFunctions::GetClassNameString<A>()]["traits"][HelperFunctions::GetClassNameString<A>()];
                        static_cast<A *>(this)->InternalDeserialize(jsonInner);
                    }
                }
            }
        }

        template <typename A>
        UIBuilder InternalBuildEditorUIForOne()
        {
            if constexpr (has_build_editor_ui<A>::value)
            {
                UIBuilder builder = static_cast<A *>(this)->BuildEditorUI();
                builder.SetName(HelperFunctions::GetClassNameString<A>());
                return builder;
            }
            else
            {
                UIBuilder builder = UIBuilder();
                builder.SetName(HelperFunctions::GetClassNameString<A>());
                return builder;
            }
        }

        template <typename A>
        static void AddToECSRegistryIDsMap()
        {

            entt::meta<A>().type(entt::hashed_string(std::to_string(staticTypeID).c_str()));
            entt::meta<A>().template data<&MakeComponent<T>::staticComponentName>(entt::hashed_string(std::string(staticComponentName + "_type_id").c_str()));
            entt::meta<A>().template func<&ECSRegistry::AddComponentToEntity<A>>(entt::hashed_string(std::string("AddComponent").c_str()));
            entt::meta<A>().template func<&ECSRegistry::EraseComponentFromEntity<A>>(entt::hashed_string(std::string("RemoveComponent").c_str()));
            entt::meta<A>().template func<&ECSRegistry::GetComponentFromEntity<A>>(entt::hashed_string(std::string("GetComponent").c_str()));
        }
    };

    namespace ObjectInternals
    {
        class ParentlessTag
        {
        };
    }

    namespace Internals
    {
        template <typename T>
        class DefaultComponent : public Reflection::IsInitializedStatically<DefaultComponent<T>>
        {
        public:
            static void InitializeStatically()
            {

                static_assert(std::is_base_of<MakeComponent<T>, T>::value, "Make sure default component is derived from MakeComponent<T>!");
                std::string componentPath = T().GetComponentMenuPath();
                ComponentInternals::ComponentStatics::defaultComponentMenuMap[componentPath] = entt::type_id<T>().hash();
            }

            virtual std::string GetComponentMenuPath() = 0;
        };
    }

}