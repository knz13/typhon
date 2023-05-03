#include "rendering_engine.h"
#ifdef __APPLE__
#include "macos/macos_engine.h"
#endif


std::unique_ptr<PlatformSpecificRenderingEngine> RenderingEngine::platformSpecificRenderingEngine;

void RenderingEngine::PassPlatformSpecificViewPointer(void* view) {
    if(platformSpecificRenderingEngine) {
        //platformSpecificRenderingEngine.get()->ReceivePlatformSpecificViewPointer(view);
        
        std::string vertexShader = R"(
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
    FragColor = vec4(vertexColor, 1.0);
}
        )";

        auto vertResult = ShaderCompiler::CompileGLSLToPlatformSpecific(vertexShader,"Vertex",ShaderType::Vertex);
        auto fragResult = ShaderCompiler::CompileGLSLToPlatformSpecific(fragShader,"Frag",ShaderType::Fragment);

        if(!vertResult.Valid()){
            std::cout << vertResult.error << std::endl;
            return;
        }
        if(!fragResult.Valid()){
            std::cout << fragResult.error << std::endl;
            return;
        }
        


        platformSpecificRenderingEngine.get()->SetVertexShader(vertResult);
        platformSpecificRenderingEngine.get()->SetFragmentShader(fragResult);

        std::cout << "Succeeded on attaching shaders!" << std::endl;
    }
}

void RenderingEngine::InitializeEngine() {
    #ifdef __APPLE__
    platformSpecificRenderingEngine = std::make_unique<MacOSEngine>();
    #endif 
};
