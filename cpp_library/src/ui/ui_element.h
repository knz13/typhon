#pragma once
#include "../general.h"
#include <sstream>

class UIElement
{
public:
    UIElement(json &jsonOutput) : elementOnJSON(jsonOutput){};

    UIElement AddStringField(std::string name, std::string &value)
    {
        json element = json::object();
        element[name] = json::object();
        element[name]["address"] = HelperFunctions::GetStringFromStringStreamFunction([&](std::stringstream &ss)
                                                                                      { ss << reinterpret_cast<int64_t>(value.data()); });
        element[name]["type"] = "vec2";
        element[name]["type"] = "string";
        element[name]["current_value"] = value;

        elementOnJSON.push_back(element);

        return UIElement(elementOnJSON);
    };

    UIElement AddFloatField(std::string name, float &value)
    {
        json element = json::object();
        element[name] = json::object();
        element[name]["address"] = HelperFunctions::GetStringFromStringStreamFunction([&](std::stringstream &ss)
                                                                                      { ss << reinterpret_cast<int64_t>(&value); });
        element[name]["type"] = "vec2";
        element[name]["type"] = "float";
        element[name]["current_value"] = value;

        elementOnJSON.push_back(element);

        return UIElement(elementOnJSON);
    };

    UIElement AddVectorField(std::string name, Vector2f &value)
    {
        json element = json::object();
        element[name] = json::object();
        element[name]["address"] = HelperFunctions::GetStringFromStringStreamFunction([&](std::stringstream &ss)
                                                                                      { ss << reinterpret_cast<int64_t>(&value.x) << " " << reinterpret_cast<int64_t>(&value.y); });
        element[name]["type"] = "vec2";
        std::ostringstream ss;
        ss << value.x << " " << value.y;
        element[name]["current_value"] = ss.str();

        elementOnJSON.push_back(element);

        return UIElement(elementOnJSON);
    }

    UIElement AddVectorField(std::string name, Vector3f &value)
    {
        json element = json::object();
        element[name] = json::object();
        element[name]["address"] = HelperFunctions::GetStringFromStringStreamFunction([&](std::stringstream &ss)
                                                                                      { ss << reinterpret_cast<int64_t>(&value.x) << " " << reinterpret_cast<int64_t>(&value.y) << " " << reinterpret_cast<int64_t>(&value.z); });
        element[name]["type"] = "vec3";
        std::ostringstream ss;
        ss << value.x << " " << value.y << " " << value.z;
        element[name]["current_value"] = ss.str();

        elementOnJSON.push_back(element);

        return UIElement(elementOnJSON);
    }

private:
    json &elementOnJSON;
};