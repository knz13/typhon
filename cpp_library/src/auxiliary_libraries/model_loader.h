#pragma once
#include "../auxiliary_libraries_helpers/auxiliary_library.h"

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

class ModelLoader : public AuxiliaryLibrary<ModelLoader>
{
public:
    static void InitializeLibrary(){

    };
    static void UnloadLibrary(){

    };

    static ModelLoaderResult LoadModelFromFile(std::string filePath)
    {
        std::cout << "Loading model from path: " << filePath << std::endl;

        if (!LibraryLoaded())
        {
            return {};
        }

        auto func = GetLibrary()->get_function<ModelLoaderResult(std::string)>("LoadModelFile");
        
        if (func == nullptr)
        {
            std::cout << "FUNCTION WAS NOT VALID!" << std::endl;
            return {};
        }

        auto val = func(filePath);

        return val;
    }

    static std::string GetLibraryName()
    {
        return "model_loader";
    };
};