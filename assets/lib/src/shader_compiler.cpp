#include "shader_compiler.h"


shaderc::Compiler ShaderCompiler::compiler = shaderc::Compiler();

ShaderSPIRVCompilationResult ShaderCompiler::CompileToSPIRV(std::string shaderSource,std::string shaderName,shaderc_shader_kind kind) {
    shaderc::CompileOptions options;
    options.SetAutoBindUniforms(true);
    options.SetAutoMapLocations(true);
    options.SetTargetEnvironment(shaderc_target_env_opengl,0);

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