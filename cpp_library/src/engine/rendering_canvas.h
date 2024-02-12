#pragma once
#include "../utils/general.h"

class RenderingCanvas
{
public:
    virtual void Render() = 0;
    virtual ~RenderingCanvas() = default;

    Color clearColor = Color::Black;
};