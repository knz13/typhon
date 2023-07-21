#include "exports.h"
#include "vendor/assimp/include/assimp/Importer.hpp"

ModelLoaderResult LoadModelFile(std::string modelFilePath)
{
    return AssimpLoadModelFromFile(modelFilePath);
}