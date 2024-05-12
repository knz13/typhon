#pragma once
#include "../../rendering_engine.h"
#ifdef __OBJC__
#include "Foundation/Foundation.h"
#include <Metal/Metal.h>
#include <QuartzCore/CAMetalLayer.h>
#endif
class MetalRenderingEngine : public PlatformSpecificRenderingEngine
{
public:
    void InitializeRenderingEngine() override;
    void UnloadRenderingEngine() override;
    void Render(RenderingCanvas &canvas) override;

private:
#ifdef __OBJC__
    id<MTLDevice> device;
    id<MTLCommandQueue> commandQueue;
    MTLRenderPassDescriptor *renderPassDescriptor = nullptr;
    CAMetalLayer *layer = nullptr;
#endif
};
