#include "exports.h"
#include "shader_compiler.h"


CompilationResult CompileGLSLToPlatformSpecific(std::string shaderText,std::string shaderName,int64_t shaderType) {
    

    shaderc_shader_kind kind;
    CompilationResult result;

    switch(shaderType){
        case 0:
            kind = shaderc_shader_kind::shaderc_vertex_shader;
            break;
        case 1:
            kind = shaderc_shader_kind::shaderc_fragment_shader;
            break;
        default:
            kind = shaderc_shader_kind::shaderc_vertex_shader;
            break;
    }
    
    auto firstCompilationResult = ShaderCompiler::CompileToSPIRV(shaderText,shaderName,kind);
    if(!firstCompilationResult.Succeeded()){
        result.error = firstCompilationResult.error;
        return result;
    }   

    #ifndef __SHADER_COMPILER_TESTING__
        auto finalResult = ShaderCompiler::CompileToPlatformSpecific(firstCompilationResult);
    #else
        #ifdef __APPLE__
            auto finalResult = ShaderCompiler::CompileToPlatformSpecific(firstCompilationResult,"MACOS");
        #endif
        #ifdef _WIN32
            auto finalResult = ShaderCompiler::CompileToPlatformSpecific(firstCompilationResult,"WINDOWS");
        #endif 
    #endif

    std::string finalJSON = finalResult.jsonResources.dump();

    result.result = true;
    result.jsonResources = finalJSON;
    result.shaderText = finalResult.shaderText;

    return result;



}