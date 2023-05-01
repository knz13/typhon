#include <iostream>
#include <algorithm>
#include "catch2/catch_test_macros.hpp"
#include "../src/shader_compiler.h"


TEST_CASE("Simple tests") {
    std::string simpleVertexGLSLShader = R"(
#version 330 core

layout (location = 0) in vec3 aPos;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main() {
    gl_Position = projection * view * model * vec4(aPos, 1.0);
}
    )";
    auto result = ShaderCompiler::CompileToSPIRV(simpleVertexGLSLShader,"SomeFile",shaderc_shader_kind::shaderc_fragment_shader);

    REQUIRE(!result.Succeeded());

    result = ShaderCompiler::CompileToSPIRV(simpleVertexGLSLShader,"SomeFile",shaderc_shader_kind::shaderc_vertex_shader);
    std::cout << result.error << std::endl;
    REQUIRE(result.Succeeded());


    auto macosResult = ShaderCompiler::CompileToPlatformSpecific(result,"MACOS");

    REQUIRE(macosResult.Succeeded());

    for(auto& a : macosResult.resources.uniform_buffers) {
        std::cout << a.name << "," << a.type_id.operator unsigned int() << std::endl;
    }




}