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
#define TYPHON_EXPORT __declspec(dllexport)
#else
#define TYPHON_EXPORT
#endif

#ifdef __cplusplus
extern "C"
{
#endif

    //__BEGIN__CPP__EXPORTS__

    TYPHON_EXPORT void passPlatformSpecificViewPointer(void *window);

    TYPHON_EXPORT void setPlatformSpecificWindowSizeAndPos(double x, double y, double width, double height);
    TYPHON_EXPORT void *getPlatformSpecificPointer();
    TYPHON_EXPORT bool initializeCppLibrary();
    TYPHON_EXPORT void onMouseMove(double positionX, double positionY);
    TYPHON_EXPORT void onKeyboardKeyDown(int64_t input);
    TYPHON_EXPORT void onKeyboardKeyUp(int64_t input);
    TYPHON_EXPORT void onUpdateCall(double dt);
    TYPHON_EXPORT void onRenderCall(double dt);
    TYPHON_EXPORT void passProjectPath(const char *path);
    TYPHON_EXPORT void attachEnqueueRender(EnqueueObjectRender func);
    TYPHON_EXPORT void attachOnChildrenChanged(OnChildrenChangedFunc func);
    TYPHON_EXPORT void unloadLibrary();
    TYPHON_EXPORT void createObjectFromClassID(int64_t classID);
    TYPHON_EXPORT char *getInstantiableClasses();
    TYPHON_EXPORT char *getInstantiableComponents();
    TYPHON_EXPORT bool isEngineInitialized();
    TYPHON_EXPORT bool isRenderingEngineInitialized();

    TYPHON_EXPORT AliveObjectsArray getAliveParentlessObjects();
    TYPHON_EXPORT const char *getObjectNameByID(int64_t id);
    TYPHON_EXPORT void removeObjectByID(int64_t id);
    TYPHON_EXPORT const char *getObjectSerializationByID(int64_t id);
    TYPHON_EXPORT const char *getObjectInspectorUIByID(int64_t id);
    TYPHON_EXPORT const char *getObjectChildTree(int64_t id);
    TYPHON_EXPORT bool setObjectParent(int64_t objectID, int64_t parentID);
    TYPHON_EXPORT bool setObjectName(int64_t objectID, const char *str, int64_t size);
    TYPHON_EXPORT bool removeObjectFromParent(int64_t objectID);
    TYPHON_EXPORT char *getContextMenuForFilePath(const char *filePath, int64_t size);
    TYPHON_EXPORT void loadModelFromPath(const char *filePath, int64_t size);
    TYPHON_EXPORT void addComponentToObject(int64_t objectID, int64_t componentClassID);

    //__END__CPP__EXPORTS__

#ifdef __cplusplus
}
#endif
