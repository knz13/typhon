
#pragma once
#include "../../engine/rendering_canvas.h"

class ProjectSelectionCanvas : public RenderingCanvas
{
public:
    void Render() override;
    ~ProjectSelectionCanvas() = default;
};