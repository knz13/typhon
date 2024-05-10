#pragma once
#include <vector>
#include <string>

// model_loader interface

namespace ModelLoaderInterface
{

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

}

// shader_compiler interface

namespace ShaderCompilerInterface
{

    struct CompilationResult
    {
        std::string shaderText;
        std::string jsonResources;
        std::string error;
        bool result;

        CompilationResult(
            std::string shaderText,
            std::string jsonResources,
            std::string error,
            bool result) : shaderText(shaderText), jsonResources(jsonResources), error(error), result(result){};

        CompilationResult() : shaderText(""), jsonResources(""), error(""), result(false){};
    };

}