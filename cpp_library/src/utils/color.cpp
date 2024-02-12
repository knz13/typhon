#include "color.h"


Color Color::White = Color(255, 255, 255);
Color Color::Black = Color(0, 0, 0);
Color Color::Red = Color(255, 0, 0);
Color Color::Green = Color(0, 255, 0);
Color Color::Blue = Color(0, 0, 255);


Color::Color(int r, int g, int b)
	:color(glm::vec3( static_cast<float>(r)/255,static_cast<float>(g)/255,static_cast<float>(b)/255))
{
}

Color::Color(float r, float g, float b)
	:color({r/255,g/255,b/255})
{
}



Color::~Color()
{
}

glm::vec3 Color::Get()
{
	return glm::vec3(color.x*255,color.y*255,color.z*255);
}

const glm::vec3& Color::GetNormalized() const
{
	return color;
}


