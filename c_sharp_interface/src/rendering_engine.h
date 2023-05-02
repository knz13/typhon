#pragma once
#include "general.h"
#include "shader_compiler.h"



class PlatformSpecificRenderingEngine {
public:
    virtual void EnqueueRender() {};
    virtual void ReceivePlatformSpecificViewPointer(void* view) {};
    virtual void SetFragmentShader(ShaderPlatformSpecificCompilationResult& shaderSource) {}
    virtual void SetVertexShader(ShaderPlatformSpecificCompilationResult& shaderSource) {}

};

class RenderingEngine {
public:

    static void InitializeEngine();

    static void UnloadEngine() {
        PassPlatformSpecificViewPointer(nullptr);
    };


    static void PassPlatformSpecificViewPointer(void* view) {
        if(platformSpecificRenderingEngine) {
            platformSpecificRenderingEngine.get()->ReceivePlatformSpecificViewPointer(view);
        }
    };

private:
    static std::unique_ptr<PlatformSpecificRenderingEngine> platformSpecificRenderingEngine;
    
};