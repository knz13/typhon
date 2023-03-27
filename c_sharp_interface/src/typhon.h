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

struct ClassesArray {
    int64_t* array;
    const char** stringArray;
    int64_t stringArraySize;
    int64_t size;
};

enum InputType {
    
};


#ifdef __cplusplus
extern "C" {
#endif

    FFI_PLUGIN_EXPORT bool initializeCppLibrary();
    
    
    //Related to GameObject
    FFI_PLUGIN_EXPORT void attachCreateGameObjectFunction(CreateGameObjectFunc func);
    FFI_PLUGIN_EXPORT void attachRemoveGameObjectFunction(RemoveGameObjectFunc func);
    FFI_PLUGIN_EXPORT RemoveObjectFunc attachOnRemoveObjectFunction();
    FFI_PLUGIN_EXPORT FindFrameFunc attachFindFrameFunction();
    FFI_PLUGIN_EXPORT AIFunc attachAIFunction();
    FFI_PLUGIN_EXPORT SetDefaultsFunc attachSetDefaultsFunction();
    FFI_PLUGIN_EXPORT UpdateFunc attachUpdateFunction();
    FFI_PLUGIN_EXPORT PreDrawFunc attachPreDrawFunction();
    FFI_PLUGIN_EXPORT PostDrawFunc attachPostDrawFunction();
    FFI_PLUGIN_EXPORT void attachScalePointerToGameObject(int id,double* scalePointerX,double* scalePointerY);
    FFI_PLUGIN_EXPORT void attachPositionPointersToGameObject(int id,double* positionX,double* positionY);

    //Related to Engine Menus

    FFI_PLUGIN_EXPORT ClassesArray getClassesToAddToHierarchyMenu();

    FFI_PLUGIN_EXPORT void addGameObjectFromClassID(int64_t id);

#ifdef __cplusplus
}
#endif

