#pragma once
#include "../utils/general.h"
#include "../auxiliary_libraries/shader_compiler.h"
#include <chrono>
#include "../vendor/bgfx/bgfx/include/bgfx/bgfx.h"
#include "../vendor/bgfx/bgfx/include/bgfx/platform.h"
#include "../vendor/bgfx/bx/include/bx/bx.h"
#include "rendering_canvas.h"

#define GLFW_INCLUDE_NONE
#include "../vendor/glfw/include/GLFW/glfw3.h"

#ifdef __APPLE__
#define GLFW_EXPOSE_NATIVE_COCOA
#endif

#include "../vendor/glfw/include/GLFW/glfw3native.h"

class PlatformSpecificRenderingEngine
{
public:
    // General
    virtual void InitializeRenderingEngine() = 0;
    virtual void UnloadRenderingEngine() = 0;
    virtual void Render(RenderingCanvas &canvas) = 0;
};

class RenderingEngine
{
public:
    /*  static PlatformSpecificRenderingEngine *GetPlatformSpecificEngine()
     {
         return nullptr;
     } */

    static void InitializeEngine();

    static void SetCurrentCanvas(std::shared_ptr<RenderingCanvas> canvas)
    {
        currentCanvas = canvas;
    }

    static void SetUpdateFunction(std::function<void(double)> func)
    {
        updateFunc = func;
    };

    static void Render();

    static bool isRunning()
    {
        if (!bgfxInitialized || glfwWindow == nullptr)
        {
            return false;
        }

        return !glfwWindowShouldClose(glfwWindow);
    };

    static void HandleEvents();

    static bool HasInitialized()
    {
        return bgfxInitialized;
    };

    static GLFWwindow *GetWindow()
    {
        return glfwWindow;
    };

    static void UnloadEngine();

    static void *GetPlatformSpecificPointer();

    static glm::vec2 GetWindowSize()
    {
        return glm::vec2(windowWidth, windowHeight);
    }

private:
    static void glfwKeyCallback(GLFWwindow *window, int key, int scancode, int action, int mods);

    static void glfwErrorCallback(int error, const char *description);

    static int windowWidth;
    static int windowHeight;
    static bool bgfxInitialized;
    static std::shared_ptr<RenderingCanvas> currentCanvas;
    static double lastTime;
    static GLFWwindow *glfwWindow;
    static bgfx::ViewId mainViewId;
    static std::function<void(double)> updateFunc;
    static std::shared_ptr<PlatformSpecificRenderingEngine> platformSpecificEngine;
};