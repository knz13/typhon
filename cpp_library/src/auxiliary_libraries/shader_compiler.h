#pragma once
#include "../utils/general.h"
#include "../auxiliary_libraries_helpers/auxiliary_library.h"

struct ShaderCompilationResult
{
    std::string shaderText = "";
    json jsonResources;
    std::string error = "";
    bool result = false;

    bool Valid()
    {
        return result == true;
    }
};
struct CompilationResult
{
    std::string shaderText = "";
    std::string jsonResources = "";
    std::string error = "";
    bool result = false;
};

enum class ShaderType
{
    Vertex = 0,
    Fragment = 1
};

class ShaderCompiler : public AuxiliaryLibrary<ShaderCompiler>
{
public:
    static void InitializeLibrary()
    {
    }

    static std::string GetLibraryName()
    {
        return "shader_compiler";
    }

    static void UnloadLibrary()
    {
    }

    static ShaderCompilationResult CompileGLSLToPlatformSpecific(std::string shaderText, std::string shaderName, ShaderType type)
    {
        std::cout << "Compiling shader!" << std::endl;
        if (!LibraryLoaded())
        {
            return {};
        }

        auto func = GetLibrary()->get_function<CompilationResult(std::string, std::string, int64_t)>("CompileGLSLToPlatformSpecific");

        if (func == nullptr)
        {
            std::cout << "FUNCTION WAS NOT VALID!" << std::endl;
            return {};
        }

        auto val = func(shaderText, shaderName, static_cast<int64_t>(type));

        ShaderCompilationResult res;

        res.shaderText = val.shaderText;
        res.result = val.result;
        if (res.result)
        {
            res.jsonResources = json::parse(val.jsonResources);
        }
        else
        {
            res.error = val.error;
        }

        return res;
    }
};