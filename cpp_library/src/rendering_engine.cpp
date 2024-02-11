#include "rendering_engine.h"
/* #ifdef __APPLE__
#include "macos/macos_engine.h"
#endif */

#include <stdio.h>

bool RenderingEngine::bgfxInitialized = false;
std::function<void(double)> RenderingEngine::updateFunc = [](double) {};
GLFWwindow *RenderingEngine::glfwWindow = nullptr;
bgfx::ViewId RenderingEngine::mainViewId = 0;

void RenderingEngine::Render()
{
    static int width, height;
    if (!RenderingEngine::bgfxInitialized)
    {
        return;
    }
    int oldWidth = width, oldHeight = height;
    glfwGetWindowSize(glfwWindow, &width, &height);
    if (width != oldWidth || height != oldHeight)
    {
        bgfx::reset((uint32_t)width, (uint32_t)height, BGFX_RESET_VSYNC);
        bgfx::setViewRect(mainViewId, 0, 0, bgfx::BackbufferRatio::Equal);
    }
    // This dummy draw call is here to make sure that view 0 is cleared if no other draw calls are submitted to view 0.
    bgfx::touch(mainViewId);
    // Use debug font to print information about this example.
    bgfx::dbgTextClear();
    // bgfx::dbgTextImage(bx::max<uint16_t>(uint16_t(width / 2 / 8), 20) - 20, bx::max<uint16_t>(uint16_t(height / 2 / 16), 6) - 6, 40, 12, s_logo, 160);
    bgfx::dbgTextPrintf(0, 0, 0x0f, "Press F1 to toggle stats.");
    bgfx::dbgTextPrintf(0, 1, 0x0f, "Color can be changed with ANSI \x1b[9;me\x1b[10;ms\x1b[11;mc\x1b[12;ma\x1b[13;mp\x1b[14;me\x1b[0m code too.");
    bgfx::dbgTextPrintf(80, 1, 0x0f, "\x1b[;0m    \x1b[;1m    \x1b[; 2m    \x1b[; 3m    \x1b[; 4m    \x1b[; 5m    \x1b[; 6m    \x1b[; 7m    \x1b[0m");
    bgfx::dbgTextPrintf(80, 2, 0x0f, "\x1b[;8m    \x1b[;9m    \x1b[;10m    \x1b[;11m    \x1b[;12m    \x1b[;13m    \x1b[;14m    \x1b[;15m    \x1b[0m");
    const bgfx::Stats *stats = bgfx::getStats();
    bgfx::dbgTextPrintf(0, 2, 0x0f, "Backbuffer %dW x %dH in pixels, debug text %dW x %dH in characters.", stats->width, stats->height, stats->textWidth, stats->textHeight);
    // Enable stats or debug text.
    bgfx::setDebug(true ? BGFX_DEBUG_STATS : BGFX_DEBUG_TEXT);
    // Advance to next frame. Process submitted rendering primitives.
    bgfx::frame();
}

void RenderingEngine::UnloadEngine()
{
    std::cout << "Unloading engine completely!" << std::endl;

    if (RenderingEngine::bgfxInitialized)
    {
        bgfx::shutdown();
        glfwTerminate();
        RenderingEngine::bgfxInitialized = false;
    }
};

void RenderingEngine::glfwKeyCallback(GLFWwindow *window, int key, int scancode, int action, int mods)
{
    if (action == GLFW_PRESS)
    {
        if (key == GLFW_KEY_ESCAPE)
        {
            RenderingEngine::UnloadEngine();
        }
    }
}

void RenderingEngine::HandleEvents()
{
    if (RenderingEngine::bgfxInitialized)
    {
        glfwPollEvents();
    }
}

void RenderingEngine::glfwErrorCallback(int error, const char *description)
{
    std::cout << "Error: " << error << " " << description << std::endl;
}

void *RenderingEngine::GetPlatformSpecificPointer()
{

    return nullptr;
}

void RenderingEngine::InitializeEngine()
{
    // Create a GLFW window without an OpenGL context.
    glfwSetErrorCallback(&RenderingEngine::glfwErrorCallback);

    if (!glfwInit())
    {

        return;
    }
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    glfwWindow = glfwCreateWindow(1024, 768, "helloworld", nullptr, nullptr);
    if (!glfwWindow)
    {

        return;
    }
    glfwSetWindowCloseCallback(glfwWindow, [](GLFWwindow *window)
                               { RenderingEngine::UnloadEngine(); });

    glfwSetKeyCallback(glfwWindow, &RenderingEngine::glfwKeyCallback);
    // Call bgfx::renderFrame before bgfx::init to signal to bgfx not to create a render thread.
    // Most graphics APIs must be used on the same thread that created the window.
    bgfx::renderFrame();
    // Initialize bgfx using the native window handle and window resolution.
    bgfx::Init init;
#if BX_PLATFORM_LINUX || BX_PLATFORM_BSD
    init.platformData.ndt = glfwGetX11Display();
    init.platformData.nwh = (void *)(uintptr_t)glfwGetX11Window(glfwWindow);
#elif BX_PLATFORM_OSX
    init.platformData.nwh = glfwGetCocoaWindow(glfwWindow);
#elif BX_PLATFORM_WINDOWS
    init.platformData.nwh = glfwGetWin32Window(glfwWindow);
#endif
    int width, height;
    glfwGetWindowSize(glfwWindow, &width, &height);
    init.resolution.width = (uint32_t)width;
    init.resolution.height = (uint32_t)height;
    init.resolution.reset = BGFX_RESET_VSYNC;
    if (!bgfx::init(init))
    {
        glfwDestroyWindow(glfwWindow);
        return;
    }
    // Set view 0 to the same dimensions as the window and to clear the color buffer.
    const bgfx::ViewId mainViewId = 0;
    bgfx::setViewClear(mainViewId, BGFX_CLEAR_COLOR);
    bgfx::setViewRect(mainViewId, 0, 0, bgfx::BackbufferRatio::Equal);

    RenderingEngine::bgfxInitialized = true;
};
