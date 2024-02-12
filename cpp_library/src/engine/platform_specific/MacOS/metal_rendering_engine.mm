#include "metal_rendering_engine.h"

#include "imgui_impl_metal.h"
#include "imgui_impl_glfw.h"


void MetalRenderingEngine::InitializeRenderingEngine() {
    device = MTLCreateSystemDefaultDevice();
    commandQueue = [device newCommandQueue];

    ImGui_ImplMetal_Init(device);

    NSWindow *nswin = glfwGetCocoaWindow(RenderingEngine::GetWindow());
    layer = [CAMetalLayer layer];
    layer.device = device;
    layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    nswin.contentView.layer = layer;
    nswin.contentView.wantsLayer = YES;

    renderPassDescriptor = [MTLRenderPassDescriptor new];
    


}

void MetalRenderingEngine::UnloadRenderingEngine() {
    [renderPassDescriptor dealloc];

    ImGui_ImplMetal_Shutdown();
}

void MetalRenderingEngine::Render(RenderingCanvas& canvas) {
    @autoreleasepool {
        
        int width, height;

        auto vec2Size = RenderingEngine::GetWindowSize();

        width = vec2Size.x;
        height = vec2Size.y;

        layer.drawableSize = CGSizeMake(width, height);
        id<CAMetalDrawable> drawable = [layer nextDrawable];

        glm::vec3 clear_color = canvas.clearColor.Get();

        id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(clear_color.x * 1, clear_color.y * 1, clear_color.z * 1, 1);
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture;
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];

        ImGui_ImplMetal_NewFrame(renderPassDescriptor);
        ImGui_ImplGlfw_NewFrame();
        ImGui::NewFrame();

        canvas.Render();

        ImGui::Render();
        ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), commandBuffer, renderEncoder);

        [renderEncoder endEncoding];

        [commandBuffer presentDrawable:drawable];
        [commandBuffer commit];


    }
}