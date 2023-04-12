#include "shader_compiler.h"


//TODO
bool ShaderCompiler::compileShader()
{
    return false;
}


ShaderCompiler::ShaderCompiler() {
    compiler = shaderc_compiler_initialize();

}


ShaderCompiler::~ShaderCompiler() {
    if(compiler != nullptr){
        shaderc_compiler_release(compiler);
    }
}