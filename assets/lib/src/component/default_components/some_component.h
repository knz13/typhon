#pragma once
#include "../make_component.h"

class SomeComponent : public MakeComponent<SomeComponent>, Internals::DefaultComponent<SomeComponent>
{
public:
    std::string GetComponentMenuPath() override
    {
        return "SomeComponent";
    }
};