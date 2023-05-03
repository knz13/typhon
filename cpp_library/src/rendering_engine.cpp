#include "rendering_engine.h"
#ifdef __APPLE__
#include "macos/macos_engine.h"
#endif


std::unique_ptr<PlatformSpecificRenderingEngine> RenderingEngine::platformSpecificRenderingEngine;

void RenderingEngine::PassPlatformSpecificViewPointer(void* view) {
    if(platformSpecificRenderingEngine) {
        platformSpecificRenderingEngine.get()->ReceivePlatformSpecificViewPointer(view);

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

        auto vertResult = ShaderCompiler::CompileToSPIRV(vertexShader,"Vertex",shaderc_shader_kind::shaderc_vertex_shader);
        auto fragResult = ShaderCompiler::CompileToSPIRV(fragShader,"Frag",shaderc_shader_kind::shaderc_fragment_shader);

        if(!vertResult.Succeeded()){
            std::cout << vertResult.error << std::endl;
            return;
        }
        if(!fragResult.Succeeded()){
            std::cout << fragResult.error << std::endl;
            return;
        }
        #ifdef __TYPHON_TESTING__
        auto finalVert = ShaderCompiler::CompileToPlatformSpecific(vertResult,"MACOS");
        auto finalFrag = ShaderCompiler::CompileToPlatformSpecific(fragResult,"MACOS");
        #else
        auto finalVert = ShaderCompiler::CompileToPlatformSpecific(vertResult);
        auto finalFrag = ShaderCompiler::CompileToPlatformSpecific(fragResult);
        #endif
        if(!finalVert.Succeeded()){
            std::cout << "Vert did not work!" << std::endl;
            return;
        }
        if(!finalFrag.Succeeded()){
            std::cout << "Frag did not work!" << std::endl;
            return;
        }
        


        platformSpecificRenderingEngine.get()->SetVertexShader(finalVert);
        platformSpecificRenderingEngine.get()->SetFragmentShader(finalFrag);

        std::cout << "Succeeded on attaching shaders!" << std::endl;
    
    }
}

void RenderingEngine::InitializeEngine() {
    #ifdef __APPLE__
    platformSpecificRenderingEngine = std::make_unique<MacOSEngine>();
    #endif  

    
};
