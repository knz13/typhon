#include <iostream>
#include <algorithm>
#include "catch2/catch_test_macros.hpp"
#include "../src/shader_compiler.h"


TEST_CASE("Simple tests") {
    std::string simpleVertexGLSLShader = R"(
#version 450

// Define a UBO for global settings
layout (std140, binding = 0) uniform GlobalSettings {
    mat4 viewMatrix;
    vec3 cameraPosition;
};

// Define a UBO for material properties
layout (std140, binding = 1) uniform MaterialProperties {
    vec4 materialAmbient;
    vec4 materialDiffuse;
    vec4 materialSpecular;
    float materialShininess;
};

// Input from the vertex shader
in vec3 fragPos;
in vec3 normal;

// Output color
out vec4 FragColor;

void main() {
    // Simple example of using values from the UBOs
    vec3 viewPos = vec3(inverse(viewMatrix) * vec4(0.0, 0.0, 0.0, 1.0));
    vec3 N = normalize(normal);
    vec3 L = normalize(cameraPosition - fragPos);

    // Compute the ambient, diffuse, and specular components
    vec3 ambient = materialAmbient.rgb;
    float diff = max(dot(N, L), 0.0);
    vec3 diffuse = materialDiffuse.rgb * diff;
    vec3 viewDir = normalize(viewPos - fragPos);
    vec3 reflectDir = reflect(-L, N);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), materialShininess);
    vec3 specular = materialSpecular.rgb * spec;

    // Combine the lighting components to compute the final color
    vec3 result = (ambient + diffuse + specular);
    FragColor = vec4(result, 1.0);
}
)";

    auto result = ShaderCompiler::CompileToSPIRV(simpleVertexGLSLShader,"SomeFile",shaderc_shader_kind::shaderc_fragment_shader);
    REQUIRE(result.Succeeded());


    auto macosResult = ShaderCompiler::CompileToPlatformSpecific(result,"MACOS");

    REQUIRE(macosResult.Succeeded());
    std::cout << macosResult.shaderText << std::endl;
    std::cout << macosResult.jsonResources.dump() << std::endl;
    json resourcesData = macosResult.jsonResources;
    for(auto inp : macosResult.entryPoints){
        std::cout << inp.name << "|" << inp.execution_model << std::endl;
    }

    REQUIRE(resourcesData.contains("entryPoints"));
    REQUIRE(resourcesData.contains("types"));
    REQUIRE(resourcesData.contains("inputs"));
    REQUIRE(resourcesData.contains("outputs"));
    REQUIRE(resourcesData["outputs"][0].contains("type"));
    REQUIRE(resourcesData["outputs"][0]["type"].get<std::string>() == "vec4");
    REQUIRE(resourcesData["outputs"][0]["name"].get<std::string>() == "FragColor");

    


}