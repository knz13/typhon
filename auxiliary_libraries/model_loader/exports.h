#pragma once

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include "model_loader.h"

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

    TYPHON_EXPORT ModelLoaderInterface::ModelLoaderResult LoadModelFile(std::string modelFilePath);

#ifdef __cplusplus
}
#endif
