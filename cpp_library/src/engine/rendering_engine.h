#pragma once
#include "../utils/general.h"
#include "../auxiliary_libraries/shader_compiler.h"
#include <chrono>
#include <bx/bx.h>
#include <bgfx/bgfx.h>
#include <bgfx/platform.h>

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#ifdef __APPLE__
#define GLFW_EXPOSE_NATIVE_COCOA
#endif

#include <GLFW/glfw3native.h>

class PlatformSpecificRenderingEngine
{
public:
    // General
    virtual void *GetPlatformSpecificPointer() { return nullptr; };
    virtual void InitializeRenderingEngine(){};
    virtual void UnloadRenderingEngine(){};

    // Shaders
    virtual bool LoadFragmentShader(std::string shaderName, ShaderCompilationResult &shaderSource) { return false; }
    virtual bool LoadVertexShader(std::string shaderName, ShaderCompilationResult &shaderSource) { return false; }
    virtual bool UnloadVertexShader(std::string shaderName) { return false; }
    virtual bool UnloadFragmentShader(std::string shaderName) { return false; }

    // Textures
    virtual void CreateTextureFromName(std::string name, int width, int height, std::vector<char> bufferData){};
    virtual bool UnloadTextureFromName(std::string name) { return false; };

    virtual void Render(){};

    /*  // Rendering
     virtual RenderPassData &EnqueueRenderLoadedTextureRect()
     {
         static RenderPassData temp;
         return temp;
     } */

protected:
};

class RenderingEngine
{
public:
    static PlatformSpecificRenderingEngine *GetPlatformSpecificEngine()
    {
        return nullptr;
    }

    static void InitializeEngine();

    static void SetUpdateFunction(std::function<void(double)> func){

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

private:
    static void glfwKeyCallback(GLFWwindow *window, int key, int scancode, int action, int mods);

    static void glfwErrorCallback(int error, const char *description);

    static bool bgfxInitialized;
    static GLFWwindow *glfwWindow;
    static bgfx::ViewId mainViewId;

    static std::function<void(double)> updateFunc;
};