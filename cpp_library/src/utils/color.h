#pragma once
#include "vendor/glm/glm/glm.hpp"

class Color
{
private:
    glm::vec3 color;

public:
    Color(int r, int g, int b);
    Color(float r, float g, float b);
    ~Color();

    static Color White;
    static Color Red;
    static Color Green;
    static Color Blue;
    static Color Black;

    glm::vec3 Get();
    const glm::vec3 &GetNormalized() const;
};