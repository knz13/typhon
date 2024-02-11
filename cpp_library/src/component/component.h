#pragma once
#include "../utils/generic_reflection.h"
#include "../utils/general.h"
#include "../ui/ui_builder.h"

DEFINE_HAS_SIGNATURE(has_on_create, T::Create, void (T::*)());
DEFINE_HAS_SIGNATURE(has_on_destroy, T::Destroy, void (T::*)());
DEFINE_HAS_SIGNATURE(has_serialize, T::Serialize, void (T::*)(json &));
DEFINE_HAS_SIGNATURE(has_deserialize, T::Deserialize, void (T::*)(const json &));
DEFINE_HAS_SIGNATURE(has_update, T::Update, void (T::*)(double));
DEFINE_HAS_SIGNATURE(has_build_editor_ui, T::BuildEditorUI, UIBuilder (T::*)());
DEFINE_HAS_SIGNATURE(has_title_on_editor_function, T::TitleOnEditor, std::string (*)());

namespace Typhon
{
    class Object;

    class Component
    {
    public:
        virtual void InternalUpdate(double dt){};

        virtual void InternalCreate(){};

        virtual void InternalDestroy()
        {
            removeFromObjectFunc();
        };

        virtual void InternalSerialize(json &json){};

        virtual void InternalDeserialize(const json &json){};

        virtual UIBuilder InternalBuildEditorUI()
        {
            return UIBuilder();
        }

        template <typename T>
        bool IsOfType()
        {
            if (HelperFunctions::GetClassID<T>() == typeID)
            {
                return true;
            }
            return false;
        }

        bool IsOfType(std::string typeName)
        {
            if (typeName == componentName)
            {
                return true;
            }
            return false;
        }

    private:
        std::string componentName = "";
        entt::id_type typeID = -1;
        std::function<void()> removeFromObjectFunc = []() {};

        friend class Typhon::Object;

        template <typename>
        friend class MakeComponent;

        friend class ECSRegistry;
    };
}