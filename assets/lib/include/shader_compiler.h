#pragma once
#include <iostream>
#include "shaderc/shaderc.h"
#include "shaderc_private.h"

class ShaderCompiler {
public:

    inline static std::shared_ptr<ShaderCompiler> instance = std::shared_ptr<ShaderCompiler>();

    static ShaderCompiler& getInstance() {
        if(!ShaderCompiler::instance){
            std::cout << "initializing shader compiler!" << std::endl;
            ShaderCompiler::instance = std::shared_ptr<ShaderCompiler>(new ShaderCompiler());
        }  
        return *ShaderCompiler::instance.get();
    }

    

    ShaderCompiler();
    ~ShaderCompiler();


    //TODO
    bool compileShader();

private:

    shaderc_compiler_t compiler = nullptr;



};