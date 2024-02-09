#pragma once
#include "../make_component.h"

namespace Typhon
{

    class Transform : public MakeComponent<Transform>, Internals::DefaultComponent<Transform>
    {
    public:
        std::string GetComponentMenuPath() override
        {
            return "Miscellaneous/Transform";
        }

        UIBuilder BuildEditorUI()
        {
            UIBuilder builder;

            builder.DefineFields()
                .AddVectorField("Position", position)
                .AddVectorField("Rotation", rotation)
                .AddVectorField("Scale", scale);

            return builder;
        };

        Vector3f position;
        Vector3f rotation;
        Vector3f scale;
    };

}
