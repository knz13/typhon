#include "exports.h"
#include "vendor/assimp/include/assimp/Importer.hpp"

ModelLoaderInterface::ModelLoaderResult LoadModelFile(std::string modelFilePath)
{
    return AssimpLoadModelFromFile(modelFilePath);
}