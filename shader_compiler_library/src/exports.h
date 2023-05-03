#pragma once

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>



#if _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

struct CompilationResult {
    const char* shaderText;
    bool result = false;
    const char* jsonResources;
};


#ifdef __cplusplus
extern "C" {
#endif

    
    FFI_PLUGIN_EXPORT CompilationResult CompileGLSLToPlatformSpecific(const char* shaderText,int64_t shaderType);
    

#ifdef __cplusplus
}
#endif

