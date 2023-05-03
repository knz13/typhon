#pragma once
#include "general.h"
#include "shader_compiler.h"

struct RenderingData {
    
};  

class PlatformSpecificRenderingEngine {
public:
    virtual void EnqueueRender(RenderingData data) {};
    virtual void ReceivePlatformSpecificViewPointer(void* view) {};
    virtual void SetFragmentShader(ShaderCompilationResult& shaderSource) {}
    virtual void SetVertexShader(ShaderCompilationResult& shaderSource) {}

};

class RenderingEngine {
public:

    static void InitializeEngine();

    static void UnloadEngine() {
        PassPlatformSpecificViewPointer(nullptr);
    };


    static void PassPlatformSpecificViewPointer(void* view);

private:
    static std::unique_ptr<PlatformSpecificRenderingEngine> platformSpecificRenderingEngine;
    
};