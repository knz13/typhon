#pragma once
#include "general.h"

struct RenderingData {
    
};  

class PlatformSpecificRenderingEngine {
public:
    virtual void EnqueueRender(RenderingData data) {};
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


    static void PassPlatformSpecificViewPointer(void* view);

private:
    static std::unique_ptr<PlatformSpecificRenderingEngine> platformSpecificRenderingEngine;
    
};