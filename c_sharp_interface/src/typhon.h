#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#if _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#include "mono_manager.h"
#endif

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

typedef int (*CreateGameObjectFunc)(const char*);



#ifdef __cplusplus
extern"C" {
#endif
    FFI_PLUGIN_EXPORT bool initializeCppLibrary();
    FFI_PLUGIN_EXPORT void attachCreateGameObjectFunction(CreateGameObjectFunc func);


#ifdef __cplusplus
}
#endif

