#pragma once
#include <iostream>
#include <vector>
#include <filesystem>
#include "vendor/assimp/include/assimp/Importer.hpp"
#include "vendor/assimp/include/assimp/mesh.h"
#include "vendor/assimp/include/assimp/postprocess.h"
#include "vendor/assimp/include/assimp/scene.h"
#include "../../cpp_library/src/auxiliary_libraries_helpers/auxiliary_libraries_interface.h"



#define LOG(x) std::cout << x << std::endl

class ModelLoader
{
public:
    static Assimp::Importer staticImporter;
};


ModelLoaderInterface::Mesh AssimpGetMeshData(const aiMesh *mesh);

std::vector<ModelLoaderInterface::Mesh> AssimpProcessData(const aiScene &scene);

ModelLoaderInterface::ModelLoaderResult AssimpLoadModelFromFile(std::string fileName);