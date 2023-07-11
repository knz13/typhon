#pragma once
#include "../make_component.h"


class Transform : public MakeComponent<Transform> { 
public:
    UIBuilder BuildEditorUI() {
        UIBuilder builder;

        builder.Add
    };
    

    Vector3f position;
    Vector3f rotation;
    Vector3f scale;
};