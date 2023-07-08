#pragma once

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include "general.h"
#include "keyboard_adaptations.h"


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

    //__BEGIN__CPP__EXPORTS__

    FFI_PLUGIN_EXPORT void passPlatformSpecificViewPointer(void* view);

    FFI_PLUGIN_EXPORT void setPlatformSpecificWindowSizeAndPos(double x,double y,double width,double height);
    FFI_PLUGIN_EXPORT void* getPlatformSpecificPointer();
    FFI_PLUGIN_EXPORT bool initializeCppLibrary();
    FFI_PLUGIN_EXPORT void onMouseMove(double positionX,double positionY);
    FFI_PLUGIN_EXPORT void onKeyboardKeyDown(int64_t input);
    FFI_PLUGIN_EXPORT void onKeyboardKeyUp(int64_t input);
    FFI_PLUGIN_EXPORT void onUpdateCall(double dt);
    FFI_PLUGIN_EXPORT void onRenderCall(double dt);
    FFI_PLUGIN_EXPORT void passProjectPath(const char* path);
    FFI_PLUGIN_EXPORT void attachEnqueueRender(EnqueueObjectRender func);
    FFI_PLUGIN_EXPORT void attachEnqueueOnChildrenChanged(OnChildrenChangedFunc func);
    FFI_PLUGIN_EXPORT void unloadLibrary();
    FFI_PLUGIN_EXPORT void createObjectFromClassID(int64_t classID);
    FFI_PLUGIN_EXPORT ClassesArray getInstantiableClasses();
    FFI_PLUGIN_EXPORT bool isEngineInitialized();
    FFI_PLUGIN_EXPORT AliveObjectsArray getAliveObjects();
    FFI_PLUGIN_EXPORT const char* getObjectNameByID(int64_t id);
    FFI_PLUGIN_EXPORT void removeObjectByID(int64_t id);
    FFI_PLUGIN_EXPORT const char* getObjectSerializationByID(int64_t id);
    
    //__END__CPP__EXPORTS__

#ifdef __cplusplus
}
#endif

