#include "mono_manager.h"
#include "shaderc/env.h"
#include "shaderc_private.h"

MonoManager::MonoManager() {

    if(!mono::init("mono",true)){
        _initialized = false;
        return;
    }

    _domain = deleted_unique_ptr<mono::mono_domain>(new mono::mono_domain("typhon_domain"),[](mono::mono_domain* ptr){});

    shaderc_compiler_t compiler = shaderc_compiler_initialize();
    if(compiler == NULL){
        std::cout << "compiler is null!" << std::endl;
        return;
    }
    shaderc_compilation_result_t result = shaderc_compile_into_spv(
        compiler, "#version 450\nvoid main() {}", 27,
        shaderc_shader_kind::shaderc_glsl_vertex_shader, "main.vert", "main", nullptr);
    

    
    if(result->num_errors == 0){
        std::cout << "compiled succesfully!" << std::endl;
    }

    shaderc_result_release(result);
    shaderc_compiler_release(compiler);
    

    

};

bool MonoManager::initialized()  {

    return _initialized;
}