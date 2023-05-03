#include "exports.h"
#include "shader_compiler.h"


CompilationResult CompileGLSLToPlatformSpecific(const char* shaderText,const char* shaderName,int64_t shaderType) {
    static std::vector<char> finalShaderText;
    static const char* finalShaderTextChar;
    static std::vector<char> finalShaderJSON;
    static const char* finalShaderJSONChar;
    
    finalShaderJSON.clear();
    finalShaderText.clear();
    finalShaderJSONChar = nullptr;
    finalShaderTextChar = nullptr;

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
    
    auto firstCompilationResult = ShaderCompiler::CompileToSPIRV({shaderText},{shaderName},kind);
    if(!firstCompilationResult.Succeeded()){
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

    std::vector<char> temp(finalResult.shaderText.size() + 1);
    memcpy(temp.data(),finalResult.shaderText.c_str(),finalResult.shaderText.size() + 1);
    finalShaderText = temp;
    finalShaderTextChar = finalShaderText.data();

    std::string finalJSON = finalResult.jsonResources.dump();

    std::vector<char> tempTwo(finalJSON.size() + 1);
    memcpy(tempTwo.data(),finalJSON.c_str(),finalJSON.size() + 1);
    finalShaderJSON = tempTwo;
    finalShaderJSONChar = finalShaderJSON.data();

    result.result = true;
    result.jsonResources = finalShaderJSONChar;
    result.shaderText = finalShaderTextChar;

    return result;



}