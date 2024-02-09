#include "rendering_engine.h"
/* #ifdef __APPLE__
#include "macos/macos_engine.h"
#endif */

bool RenderingEngine::bgfxInitialized = false;

void RenderingEngine::Render()
{
    if (RenderingEngine::bgfxInitialized)
    {
    }
}

void RenderingEngine::UnloadEngine()
{
    std::cout << "Unloading engine completely!" << std::endl;

    if (RenderingEngine::bgfxInitialized)
    {
    }
};

void RenderingEngine::PassPlatformSpecificViewPointer(void *window)
{

    /* std::cout << "starting bgfx section!" << std::endl;
    bgfx::PlatformData pd;

    pd.nwh = window;

    bgfx::Init bgfxInit;

    bgfxInit.platformData = pd;
#ifdef __APPLE__
    bgfxInit.type = bgfx::RendererType::Metal;

#else

#endif

    bgfxInit.resolution.width = 1500;
    bgfxInit.resolution.height = 1500;
    bgfxInit.resolution.reset = BGFX_RESET_VSYNC;

    std::cout << "initializing bgfx!" << std::endl;

    RenderingEngine::bgfxInitialized = bgfx::init(bgfxInit);

    if (!RenderingEngine::bgfxInitialized)
    {
        std::cout << "bgfx failed to initialize!" << std::endl;

        return;
    }

    std::cout << "setting debug!" << std::endl;

    bgfx::setDebug(BGFX_DEBUG_TEXT);

    std::cout << "setting view!" << std::endl;

    bgfx::setViewClear(0, BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH, 0xffA2EB00, 1.0f, 0);
    bgfx::setViewRect(0, 0, 0, 1500, 1500);

    std::cout << "frame!" << std::endl;

    bgfx::frame();

    std::cout << "view pointer passed and rendered!" << std::endl; */
}

void *RenderingEngine::GetPlatformSpecificPointer()
{

    return nullptr;
}

void RenderingEngine::InitializeEngine(){

    // platformSpecificRenderingEngine.get()->InitializeRenderingEngine();

    /* std::string vertexShader = R"(
#version 330 core

layout (location = 0) in vec3 vertexPosition;
layout (location = 1) in vec3 color;

out vec3 vertexColor;

void main() {
gl_Position = vec4(vertexPosition, 1.0);
vertexColor = color;
}
)";
    std::string fragShader = R"(
#version 330 core

in vec3 vertexColor;

out vec4 FragColor;

void main() {
FragColor = vec4(1,0,1, 1.0);
}
    )";

    auto vertResult = ShaderCompiler::CompileGLSLToPlatformSpecific(vertexShader, "Vertex", ShaderType::Vertex);
    auto fragResult = ShaderCompiler::CompileGLSLToPlatformSpecific(fragShader, "Frag", ShaderType::Fragment);

    if (!vertResult.Valid())
    {
        std::cout << vertResult.error << std::endl;
        return;
    }
    if (!fragResult.Valid())
    {
        std::cout << fragResult.error << std::endl;
        return;
    } */

    // platformSpecificRenderingEngine.get()->LoadVertexShader("MyVertex", vertResult);
    // platformSpecificRenderingEngine.get()->LoadFragmentShader("MyFragment", fragResult);
};
