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


typedef int (*AddGameObjectFunction)(int); //args: parentID=-1 if no parent, componentName= | returns: gameObjectID
typedef int (*RemoveGameObjectFunction)(int); // args: gameObjectID
typedef void (*PrintToEditorWindow)(const char*); 

#ifdef __cplusplus
extern"C" {
#endif
    FFI_PLUGIN_EXPORT void registerAddGameObjectFunction(AddGameObjectFunction func);

    FFI_PLUGIN_EXPORT int loadScriptFromString(const char* string);

    FFI_PLUGIN_EXPORT void registerRemoveGameObjectFunction(RemoveGameObjectFunction func);

    FFI_PLUGIN_EXPORT void registerPrintToEditorWindow(PrintToEditorWindow func);
#ifdef __cplusplus
}
#endif

