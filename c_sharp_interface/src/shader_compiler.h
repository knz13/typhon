#pragma once
#include <iostream>
#include "general.h"
#include "vendor/shaderc/libshaderc/include/shaderc/env.h"
#include "vendor/shaderc/libshaderc/include/shaderc/status.h"
#include "vendor/shaderc/libshaderc/include/shaderc/visibility.h"
#include "vendor/shaderc/libshaderc/include/shaderc/shaderc.hpp"
#include "vendor/spirv_cross/spirv_msl.hpp"
#include "vendor/spirv_cross/spirv_glsl.hpp"


struct ShaderSPIRVCompilationResult {
    std::vector<uint32_t> spirvBinary;
    std::string error = "";

    bool Succeeded() {
        return error == "";
    }
};

struct ShaderPlatformSpecificCompilationResult {
    std::string shaderText = "";
    spirv_cross::ShaderResources resources;

    bool Succeeded() {
        return succeeded;
    }

private:
    bool succeeded = false;

    friend class ShaderCompiler;
};

class ShaderCompiler {
public:
    

    static ShaderSPIRVCompilationResult CompileToSPIRV(std::string shaderSource,std::string shaderName,shaderc_shader_kind kind);

    #ifndef __TYPHON_TESTING__
    static ShaderPlatformSpecificCompilationResult CompileToPlatformSpecific(ShaderSPIRVCompilationResult& spirvResult) {
    #else
    static ShaderPlatformSpecificCompilationResult CompileToPlatformSpecific(ShaderSPIRVCompilationResult& spirvResult,std::string testingTarget) {
    #endif
        if(!spirvResult.Succeeded()) {
            return ShaderPlatformSpecificCompilationResult();
        }
        #ifndef __TYPHON_TESTING__
            #ifdef __APPLE__
            return CompileToPlatformSpecificInternal(spirvResult,"MACOS");
            #endif
            #ifdef _WIN32
            return CompileToPlatformSpecificInternal(spirvResult,"WINDOWS");
            #endif
        #else
            return CompileToPlatformSpecificInternal(spirvResult,testingTarget);
        #endif
    }
    



private:

    static ShaderPlatformSpecificCompilationResult CompileToPlatformSpecificInternal(ShaderSPIRVCompilationResult& spirvResult,std::string testingTarget) {
        std::shared_ptr<spirv_cross::Compiler> shaderSPIRVCompiler;
        if(testingTarget == "MACOS") {
            shaderSPIRVCompiler = std::shared_ptr<spirv_cross::Compiler>(new spirv_cross::CompilerMSL(spirvResult.spirvBinary));
        }
        if(testingTarget == "WINDOWS") {
            auto ptr = new spirv_cross::CompilerGLSL(spirvResult.spirvBinary);
            spirv_cross::CompilerGLSL::Options options;

            shaderSPIRVCompiler = std::shared_ptr<spirv_cross::Compiler>(ptr);
        }
        spirv_cross::ShaderResources resources = shaderSPIRVCompiler.get()->get_shader_resources();
        ShaderPlatformSpecificCompilationResult compilationResult;
        compilationResult.succeeded = true;
        compilationResult.shaderText = shaderSPIRVCompiler.get()->compile();
        compilationResult.resources = resources;


        return compilationResult; 
    }


    static shaderc::Compiler compiler;



};