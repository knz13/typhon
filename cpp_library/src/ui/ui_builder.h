#pragma once
#include "ui_element.h"

class UIBuilder
{
public:
    UIBuilder() : elementOnJSON(json::object())
    {
        elementOnJSON["fields"] = json::array();
    }

    UIElement DefineFields()
    {
        return UIElement(elementOnJSON["fields"]);
    };

    void SetName(std::string name)
    {
        elementOnJSON["component_name"] = name;
    }

    json &GetJSON()
    {
        return elementOnJSON;
    }

private:
    json elementOnJSON;
};