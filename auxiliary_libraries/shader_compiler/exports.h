#pragma once

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include "../auxiliary_libraries_interface.h"

#if _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

#if _WIN32
#define TYPHON_EXPORT __declspec(dllexport)
#else
#define TYPHON_EXPORT
#endif

#ifdef __cplusplus
extern "C"
{
#endif

    TYPHON_EXPORT ShaderCompilerInterface::CompilationResult CompileGLSLToPlatformSpecific(std::string shaderText, std::string shaderName, int64_t shaderType);

#ifdef __cplusplus
}
#endif
