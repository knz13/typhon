#pragma once
#include <iostream>
#include <vector>
#include <filesystem>
#include "vendor/assimp/include/assimp/Importer.hpp"
#include "vendor/assimp/include/assimp/mesh.h"
#include "vendor/assimp/include/assimp/postprocess.h"
#include "vendor/assimp/include/assimp/scene.h"

#define LOG(x) std::cout << x << std::endl

class ModelLoader
{
public:
    static Assimp::Importer staticImporter;
};

namespace MeshAttribute
{

    struct Vertex
    {
        bool CheckValid() const;

        void SetEqualSize();

        std::vector<float> positions;
        std::vector<float> normals;
        std::vector<float> texCoords;
        std::vector<float> tangents;
        std::vector<unsigned int> indices;
    };
};

struct Mesh
{
    std::string name;
    MeshAttribute::Vertex vertex;
    bool valid = false;
};

struct ModelLoaderResult
{
    std::vector<Mesh> meshes;
};

Mesh AssimpGetMeshData(const aiMesh *mesh);

std::vector<Mesh> AssimpProcessData(const aiScene &scene);

ModelLoaderResult AssimpLoadModelFromFile(std::string fileName);