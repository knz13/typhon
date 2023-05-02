#include "rendering_engine.h"
#ifdef __APPLE__
#include "macos/macos_engine.h"
#endif


std::unique_ptr<PlatformSpecificRenderingEngine> RenderingEngine::platformSpecificRenderingEngine;


void RenderingEngine::InitializeEngine() {
    #ifdef __APPLE__
    platformSpecificRenderingEngine = std::make_unique<MacOSEngine>();
    #endif
    
};