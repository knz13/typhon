#pragma once
#include "ui_element.h"



class UIBuilder {
public:
    UIBuilder(std::string nameAtTop = "") : elementOnJSON(json::object()) {
    }

    UIElement DefineBuild() {
        return UIElement(elementOnJSON);
    };

private:
    json elementOnJSON;

};