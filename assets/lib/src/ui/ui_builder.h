#pragma once
#include "ui_element.h"



class UIBuilder {
public:
    UIBuilder() : elementOnJSON(json::object()) {
    }

    UIElement DefineBuild() {
        elementOnJSON["children"] = json::array();
        return UIElement(elementOnJSON["children"]);
    };

    void SetName(std::string name) {
        std::cout << "calling set name!" << std::endl;
        std::cout << "current => " << elementOnJSON.dump() << std::endl;
        elementOnJSON["component_name"] = name;
    }

    json& GetJSON() {
        return elementOnJSON;
    }

private:
    json elementOnJSON;

};