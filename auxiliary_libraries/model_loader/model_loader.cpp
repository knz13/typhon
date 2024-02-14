#include "model_loader.h"

Assimp::Importer ModelLoader::staticImporter;

bool ModelLoaderInterface::MeshAttribute::Vertex::CheckValid() const
{
    return (positions.size() == normals.size()) && (positions.size() / 3 == texCoords.size() / 2) && (positions.size() == tangents.size()) && (positions.size() != 0);
}

void ModelLoaderInterface::MeshAttribute::Vertex::SetEqualSize()
{
    size_t largestAttribute = positions.size() / 3;

    if (positions.size() == 0)
    {
        return;
    }

    if (normals.size() / 3 < largestAttribute)
    {
        size_t oldSize = normals.size();
        normals.resize(normals.size() + largestAttribute * 3);
        std::fill(normals.begin() + oldSize, normals.end(), 0.0f);
    }
    if (texCoords.size() / 2 < largestAttribute)
    {
        size_t oldSize = texCoords.size();
        texCoords.resize(texCoords.size() + largestAttribute * 2);
        std::fill(texCoords.begin() + oldSize, texCoords.end(), 0.0f);
    }
    if (tangents.size() / 3 < largestAttribute)
    {
        size_t oldSize = tangents.size();
        tangents.resize(tangents.size() + largestAttribute * 3);
        std::fill(tangents.begin() + oldSize, tangents.end(), 0.0f);
    }
}

ModelLoaderInterface::Mesh AssimpGetMeshData(const aiMesh *mesh)
{
    aiFace *face;
    ModelLoaderInterface::MeshAttribute::Vertex vertex;

    for (unsigned int v = 0; v < mesh->mNumVertices; v++)
    {
        vertex.positions.push_back(mesh->mVertices[v].x);
        vertex.positions.push_back(mesh->mVertices[v].y);
        vertex.positions.push_back(mesh->mVertices[v].z);

        vertex.normals.push_back(mesh->mNormals[v].x);
        vertex.normals.push_back(mesh->mNormals[v].y);
        vertex.normals.push_back(mesh->mNormals[v].z);

        if (mesh->HasTextureCoords(0))
        {
            vertex.texCoords.push_back(mesh->mTextureCoords[0][v].x);
            vertex.texCoords.push_back(mesh->mTextureCoords[0][v].y);
        }
        else
        {
            vertex.texCoords.push_back(0);
            vertex.texCoords.push_back(0);
        }

        if (mesh->HasTangentsAndBitangents())
        {
            vertex.tangents.push_back(mesh->mTangents[v].x);
            vertex.tangents.push_back(mesh->mTangents[v].y);
            vertex.tangents.push_back(mesh->mTangents[v].z);
        }
        else
        {
            vertex.tangents.push_back(0);
            vertex.tangents.push_back(0);
            vertex.tangents.push_back(0);
        }
    }

    if (mesh->mMaterialIndex >= 0)
    {
        /*
        aiMaterial* material = m_ModelScene->mMaterials[mesh->mMaterialIndex];
        vector<Texture> diffuseMaps = loadMaterialTextures(material, aiTextureType_DIFFUSE, "texture_diffuse");
        m_Textures.insert(m_Textures.end(), diffuseMaps.begin(), diffuseMaps.end());

        vector<Texture> specularMaps = loadMaterialTextures(material, aiTextureType_SPECULAR, "texture_specular");
        m_Textures.insert(m_Textures.end(), specularMaps.begin(), specularMaps.end());
        */
    }

    for (unsigned int i = 0; i < mesh->mNumFaces; i++)
    {
        face = &mesh->mFaces[i];
        vertex.indices.push_back(face->mIndices[0]);
        vertex.indices.push_back(face->mIndices[1]);
        vertex.indices.push_back(face->mIndices[2]);
    }

    ModelLoaderInterface::Mesh result;
    result.vertex = vertex;
    result.valid = true;

    return result;
}

std::vector<ModelLoaderInterface::Mesh> AssimpProcessData(const aiScene &scene)
{
    std::vector<ModelLoaderInterface::Mesh> loadedMeshes;
    if (scene.mNumMeshes > 0)
    {
        for (unsigned int i = 0; i < scene.mNumMeshes; i++)
        {
            ModelLoaderInterface::Mesh meshDataResult = AssimpGetMeshData(scene.mMeshes[i]);
            if (meshDataResult.valid)
            {
                meshDataResult.name = scene.mMeshes[i]->mName.C_Str();
                loadedMeshes.push_back(meshDataResult);
            }
        }
    }
    return loadedMeshes;
}

ModelLoaderInterface::ModelLoaderResult AssimpLoadModelFromFile(std::string fileName)
{
    if (!std::filesystem::exists(fileName))
    {
        LOG("Couldn't load model at " + fileName + " because the file was not found!");
        return ModelLoaderInterface::ModelLoaderResult();
    }

    const aiScene *modelScene = ModelLoader::staticImporter.ReadFile(fileName, aiProcess_GenNormals | aiProcess_FlipUVs | aiProcess_ValidateDataStructure | aiProcess_Triangulate | aiProcess_EmbedTextures | aiProcess_FixInfacingNormals | aiProcess_OptimizeMeshes);

    if (!modelScene)
    {
        LOG("Couldn't load model at " + fileName);
        return ModelLoaderInterface::ModelLoaderResult();
    }
    else
    {

        std::vector<ModelLoaderInterface::Mesh> loadedMeshes = AssimpProcessData(*modelScene);
        if (loadedMeshes.size() == 0)
        {
            return ModelLoaderInterface::ModelLoaderResult();
        }
        ModelLoaderInterface::ModelLoaderResult finalResult;
        finalResult.meshes = loadedMeshes;
        return finalResult;
    }
}