#include "rendering_engine.h"
/* #ifdef __APPLE__
#include "macos/macos_engine.h"
#endif */

#include "imgui.h"
#include "imgui_impl_glfw.h"

#ifdef __APPLE__
#include "platform_specific/MacOS/metal_rendering_engine.h"
#endif

#include <stdio.h>

bool RenderingEngine::bgfxInitialized = false;
std::function<void(double)> RenderingEngine::updateFunc = [](double) {};
GLFWwindow *RenderingEngine::glfwWindow = nullptr;
std::shared_ptr<RenderingCanvas> RenderingEngine::currentCanvas = nullptr;
bgfx::ViewId RenderingEngine::mainViewId = 0;
double RenderingEngine::lastTime = 0;
std::shared_ptr<PlatformSpecificRenderingEngine> RenderingEngine::platformSpecificEngine = nullptr;
int RenderingEngine::windowWidth = 0;
int RenderingEngine::windowHeight = 0;


void RenderingEngine::Render()
{

    if (!RenderingEngine::bgfxInitialized)
    {
        return;
    }
    auto currentTime = glfwGetTime();
    int oldWidth = windowWidth, oldHeight = windowHeight;
    glfwGetWindowSize(glfwWindow, &windowWidth, &windowHeight);
    if (windowWidth != oldWidth || windowHeight != oldHeight)
    {
        bgfx::reset((uint32_t)windowWidth, (uint32_t)windowHeight, BGFX_RESET_VSYNC);
        bgfx::setViewRect(mainViewId, 0, 0, bgfx::BackbufferRatio::Equal);
    }

    updateFunc(currentTime - lastTime);
    // This dummy draw call is here to make sure that view 0 is cleared if no other draw calls are submitted to view 0.
    bgfx::touch(mainViewId);

    if(platformSpecificEngine != nullptr)
    {
        platformSpecificEngine->Render(*currentCanvas);
    }

    // Advance to next frame. Process submitted rendering primitives.
    bgfx::frame();

    lastTime = currentTime;
}

void RenderingEngine::UnloadEngine()
{
    std::cout << "Unloading engine completely!" << std::endl;

    if (RenderingEngine::bgfxInitialized)
    {
        if (RenderingEngine::platformSpecificEngine != nullptr)
        {

            RenderingEngine::platformSpecificEngine->UnloadRenderingEngine();
        }

        bgfx::shutdown();
        ImGui_ImplGlfw_Shutdown();
        ImGui::DestroyContext();

        glfwDestroyWindow(glfwWindow);
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

#ifdef __APPLE__
    RenderingEngine::platformSpecificEngine = std::make_shared<MetalRenderingEngine>();
#endif

    // Initial ImGui setup

    ImGui::CreateContext();
    ImGuiIO &io = ImGui::GetIO();
    (void)io;
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard; // Enable Keyboard Controls
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;  // Enable Gamepad Controls

    // Setup style
    ImGui::StyleColorsDark();

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

    // initialize ImGui

    RenderingEngine::platformSpecificEngine->InitializeRenderingEngine();
};
