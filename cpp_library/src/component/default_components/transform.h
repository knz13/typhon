#pragma once
#include "../make_component.h"


class Transform : public MakeComponent<Transform> { 
public:
    UIBuilder BuildEditorUI() {
        UIBuilder builder;

        builder.DefineBuild()
            .AddVectorField("Position",position)
            .AddVectorField("Rotation",rotation)
            .AddVectorField("Scale",scale);
        
        return builder;
    };
    

    Vector3f position;
    Vector3f rotation;
    Vector3f scale;
};