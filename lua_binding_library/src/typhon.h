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


typedef int (*CreateComponentFunction)(int);

FFI_PLUGIN_EXPORT void registerCreateComponentFunction(CreateComponentFunction func);

FFI_PLUGIN_EXPORT int load_script_from_string(char* string,int stringLen);


