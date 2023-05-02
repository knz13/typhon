#include "shader_compiler.h"


shaderc::Compiler ShaderCompiler::compiler = shaderc::Compiler();

ShaderSPIRVCompilationResult ShaderCompiler::CompileToSPIRV(std::string shaderSource,std::string shaderName,shaderc_shader_kind kind) {
    shaderc::CompileOptions options;
    options.SetSourceLanguage(shaderc_source_language_glsl);
    options.SetAutoMapLocations(true);
    options.SetAutoBindUniforms(true);

    ShaderSPIRVCompilationResult finalResult;
    shaderc::SpvCompilationResult result = compiler.CompileGlslToSpv(shaderSource,kind,shaderName.c_str(),options);
    if(result.GetCompilationStatus() != shaderc_compilation_status_success){
        finalResult.error = result.GetErrorMessage();
        return finalResult;
    }
    else {
        finalResult.spirvBinary = {result.cbegin(),result.cend()};
        return finalResult;
    }
    
}