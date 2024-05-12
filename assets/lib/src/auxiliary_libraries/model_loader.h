#pragma once
#include "../auxiliary_libraries_helpers/auxiliary_library.h"

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