#pragma once

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>



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
    std::string shaderText = "";
    std::string jsonResources = "";
    std::string error = "";
    bool result = false;
};


#ifdef __cplusplus
extern "C" {
#endif

    
    FFI_PLUGIN_EXPORT CompilationResult CompileGLSLToPlatformSpecific(std::string shaderText,std::string shaderName,int64_t shaderType);
    

#ifdef __cplusplus
}
#endif

