#pragma once

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include "general.h"
#include "keyboard_adaptations.h"

#ifdef _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

#ifdef _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

#ifdef __cplusplus
extern "C"
{
#endif

    //__BEGIN__CPP__EXPORTS__

    FFI_PLUGIN_EXPORT void passPlatformSpecificViewPointer(void *window);

    FFI_PLUGIN_EXPORT void setPlatformSpecificWindowSizeAndPos(double x, double y, double width, double height);
    FFI_PLUGIN_EXPORT void *getPlatformSpecificPointer();
    FFI_PLUGIN_EXPORT bool initializeCppLibrary();
    FFI_PLUGIN_EXPORT void onMouseMove(double positionX, double positionY);
    FFI_PLUGIN_EXPORT void onKeyboardKeyDown(int64_t input);
    FFI_PLUGIN_EXPORT void onKeyboardKeyUp(int64_t input);
    FFI_PLUGIN_EXPORT void onUpdateCall(double dt);
    FFI_PLUGIN_EXPORT void onRenderCall(double dt);
    FFI_PLUGIN_EXPORT void passProjectPath(const char *path);
    FFI_PLUGIN_EXPORT void attachEnqueueRender(EnqueueObjectRender func);
    FFI_PLUGIN_EXPORT void attachOnChildrenChanged(OnChildrenChangedFunc func);
    FFI_PLUGIN_EXPORT void unloadLibrary();
    FFI_PLUGIN_EXPORT void createObjectFromClassID(int64_t classID);
    FFI_PLUGIN_EXPORT char *getInstantiableClasses();
    FFI_PLUGIN_EXPORT char *getInstantiableComponents();
    FFI_PLUGIN_EXPORT bool isEngineInitialized();
    FFI_PLUGIN_EXPORT bool isRenderingEngineInitialized();

    FFI_PLUGIN_EXPORT AliveObjectsArray getAliveParentlessObjects();
    FFI_PLUGIN_EXPORT const char *getObjectNameByID(int64_t id);
    FFI_PLUGIN_EXPORT void removeObjectByID(int64_t id);
    FFI_PLUGIN_EXPORT const char *getObjectSerializationByID(int64_t id);
    FFI_PLUGIN_EXPORT const char *getObjectInspectorUIByID(int64_t id);
    FFI_PLUGIN_EXPORT const char *getObjectChildTree(int64_t id);
    FFI_PLUGIN_EXPORT bool setObjectParent(int64_t objectID, int64_t parentID);
    FFI_PLUGIN_EXPORT bool setObjectName(int64_t objectID, const char *str, int64_t size);
    FFI_PLUGIN_EXPORT bool removeObjectFromParent(int64_t objectID);
    FFI_PLUGIN_EXPORT char *getContextMenuForFilePath(const char *filePath, int64_t size);
    FFI_PLUGIN_EXPORT void loadModelFromPath(const char *filePath, int64_t size);
    FFI_PLUGIN_EXPORT void addComponentToObject(int64_t objectID, int64_t componentClassID);

    //__END__CPP__EXPORTS__

#ifdef __cplusplus
}
#endif
