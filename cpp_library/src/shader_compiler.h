#pragma once
#include <iostream>
#include "general.h"
#include "vendor/shaderc/libshaderc/include/shaderc/env.h"
#include "vendor/shaderc/libshaderc/include/shaderc/status.h"
#include "vendor/shaderc/libshaderc/include/shaderc/visibility.h"
#include "vendor/shaderc/libshaderc/include/shaderc/shaderc.hpp"
#include "vendor/spirv_cross/spirv_msl.hpp"
#include "vendor/spirv_cross/spirv_glsl.hpp"
#include "vendor/spirv_cross/spirv_reflect.hpp"


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
    json jsonResources;
    std::vector<spirv_cross::EntryPoint> entryPoints;


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
        std::string jsonData = "";
        if(testingTarget == "MACOS") {
            auto ptr = new spirv_cross::CompilerMSL(spirvResult.spirvBinary);
            shaderSPIRVCompiler = std::shared_ptr<spirv_cross::Compiler>(ptr);
            auto reflectionData = spirv_cross::CompilerReflection(spirvResult.spirvBinary);
            jsonData = reflectionData.compile();
        }
        if(testingTarget == "WINDOWS") {
            auto ptr = new spirv_cross::CompilerGLSL(spirvResult.spirvBinary);
            shaderSPIRVCompiler = std::shared_ptr<spirv_cross::Compiler>(ptr);
            auto reflectionData = spirv_cross::CompilerReflection(spirvResult.spirvBinary);
            jsonData = reflectionData.compile();
        }
        spirv_cross::ShaderResources resources = shaderSPIRVCompiler.get()->get_shader_resources();
        ShaderPlatformSpecificCompilationResult compilationResult;
        compilationResult.succeeded = true;
        compilationResult.shaderText = shaderSPIRVCompiler.get()->compile();
        compilationResult.resources = resources;
        compilationResult.entryPoints = shaderSPIRVCompiler.get()->get_entry_points_and_stages().operator std::__1::vector<spirv_cross::EntryPoint, std::__1::allocator<spirv_cross::EntryPoint>>();
        compilationResult.jsonResources = json::parse(jsonData);
        
        return compilationResult; 
    }


    static shaderc::Compiler compiler;



};