#pragma once
#include "general.h"

struct ShaderCompilationResult {
    std::string shaderText = "";
    json jsonResources;
    std::string error = "";
    bool result = false;

    bool Valid() {
        return result == true;
    }

};
struct CompilationResult {
    std::string shaderText = "";
    std::string jsonResources = "";
    std::string error = "";
    bool result = false;

};

enum class ShaderType {
    Vertex = 0,
    Fragment = 1
};

class ShaderCompiler {
public:
    static void Initialize() {

        try {
            shaderCompilerLib = std::make_shared<dylib>((std::filesystem::path(HelperStatics::projectPath) / std::filesystem::path("build")).string(),"shader_compiler_dynamic");
            std::cout << "Loaded Shader Compiler Lib!" << std::endl;
        }
        catch(std::exception& e) {
            std::cout << "Could not load dynamic library:\n" << e.what() << std::endl;
            shaderCompilerLib.reset(); 
        }
    }

    static void Unload() {
        std::cout << "Reseting shader compiler!" << std::endl;
        shaderCompilerLib.reset();
    }


    static ShaderCompilationResult CompileGLSLToPlatformSpecific(std::string shaderText,std::string shaderName,ShaderType type) {
        std::cout << "Compiling shader!" << std::endl;
        if(!shaderCompilerLib){
            return {};
        }

        auto func = shaderCompilerLib.get()->get_function<CompilationResult(std::string,std::string,int64_t)>("CompileGLSLToPlatformSpecific");

        if(func == nullptr){
            std::cout << "FUNCTION WAS NOT VALID!" << std::endl;
            return {};
        }

        auto val = func(shaderText,shaderName,static_cast<int64_t>(type));

        ShaderCompilationResult res;

        res.shaderText = val.shaderText;
        res.result = val.result;
        if(res.result) {
            res.jsonResources =json::parse(val.jsonResources);
        }
        else {
            res.error = val.error;
        }

        return res;

    }




private:
    static std::shared_ptr<dylib> shaderCompilerLib;

};