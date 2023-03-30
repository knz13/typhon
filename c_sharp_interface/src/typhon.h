#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include "general.h"

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


#ifdef __cplusplus
extern "C" {
#endif

    FFI_PLUGIN_EXPORT bool initializeCppLibrary();
    FFI_PLUGIN_EXPORT void onMouseMove(double positionX,double positionY);
    FFI_PLUGIN_EXPORT void onKeyboardKeyDown(InputKey input);
   
#ifdef __cplusplus
}
#endif

