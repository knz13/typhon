#pragma once
#include "general.h"
#include "shader_compiler.h"

struct RenderingData {
    
};  

class PlatformSpecificRenderingEngine {
public:
    virtual void EnqueueRender(RenderingData data) {};
    virtual void ReceivePlatformSpecificViewPointer(void* view) {};
    virtual void* GetPlatformSpecificPointer() {return nullptr;};
    virtual void InitializeRenderingEngine() {};
    virtual void UnloadRenderingEngine() {};
    virtual void SetFragmentShader(ShaderCompilationResult& shaderSource) {}
    virtual void SetVertexShader(ShaderCompilationResult& shaderSource) {}
};

class RenderingEngine {
public:
    

    static void InitializeEngine();

    static void UnloadEngine() {
        if(platformSpecificRenderingEngine){
            platformSpecificRenderingEngine.get()->UnloadRenderingEngine();
        }
    };

    static void* GetPlatformSpecificPointer();

    static void PassPlatformSpecificViewPointer(void* view);

private:
    static std::unique_ptr<PlatformSpecificRenderingEngine> platformSpecificRenderingEngine;
    
};