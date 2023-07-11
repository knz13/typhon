#pragma once
#include "../generic_reflection.h"
#include "../general.h"
#include "../ui/ui_builder.h"


DEFINE_HAS_SIGNATURE(has_on_create,T::Create,void (T::*) ());
DEFINE_HAS_SIGNATURE(has_on_destroy,T::Destroy,void (T::*) ());
DEFINE_HAS_SIGNATURE(has_serialize,T::Serialize,void (T::*) (json&));
DEFINE_HAS_SIGNATURE(has_deserialize,T::Deserialize,void (T::*) (const json&));
DEFINE_HAS_SIGNATURE(has_update,T::Update,void (T::*) (double));
DEFINE_HAS_SIGNATURE(has_build_editor_ui,T::BuildEditorUI,UIBuilder (T::*) ());
DEFINE_HAS_SIGNATURE(has_title_on_editor_function,T::TitleOnEditor,std::string (*)());



class Component {
public:

    virtual void Update(double dt){};

    virtual void Create() {};

    virtual void Destroy() {
        removeFromObjectFunc();
    };

    virtual void Serialize(json& json) {};

    virtual void Deserialize(const json& json) {};

    virtual UIBuilder BuildEditorUI() {
        return UIBuilder();
    }

private:
    std::string componentName = "";
    entt::id_type typeID = -1;
    std::function<void()> removeFromObjectFunc = [](){};

    friend class Object;
    template<typename>
    friend class MakeComponent;

    friend class ECSRegistry;
};
