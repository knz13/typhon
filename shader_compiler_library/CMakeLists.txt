cmake_minimum_required(VERSION 3.16)

#adding extra cmake libs

include(ExternalProject)
include(FetchContent)


#project name
project(project_shader_compiler_library)

option(SHADER_COMPILER_RUN_TESTS "Run Tests" OFF)


add_library(shader_compiler
    src/shader_compiler.cpp
)

#SPIRV-Cross setup
set(SPIRV_CROSS_ENABLE_TESTS OFF)
set(SPIRV_CROSS_CLI OFF)

add_subdirectory(${PROJECT_SOURCE_DIR}/src/vendor/spirv_cross)

target_link_libraries(shader_compiler PUBLIC spirv-cross-cpp)
target_link_libraries(shader_compiler PUBLIC spirv-cross-msl)
target_link_libraries(shader_compiler PUBLIC spirv-cross-hlsl)
target_link_libraries(shader_compiler PUBLIC spirv-cross-reflect)
target_include_directories(shader_compiler PUBLIC ${PROJECT_SOURCE_DIR}/src/vendor/spirv_cross/)



#SHADERC setup
set(SHADERC_SKIP_TESTS ON)
set(SHADERC_SKIP_EXAMPLES ON)

add_subdirectory(${PROJECT_SOURCE_DIR}/src/vendor/shaderc)

target_link_libraries(shader_compiler PUBLIC shaderc)

target_include_directories(shader_compiler PUBLIC ${PROJECT_SOURCE_DIR}/src/vendor/shaderc/libshaderc/include)
target_include_directories(shader_compiler PUBLIC ${PROJECT_SOURCE_DIR}/src/vendor/shaderc/libshaderc/src)
target_include_directories(shader_compiler PUBLIC ${PROJECT_SOURCE_DIR}/src/vendor/shaderc/libshaderc_util/include)
target_include_directories(shader_compiler PUBLIC ${PROJECT_SOURCE_DIR}/src/vendor/shaderc/libshaderc_util/src)
target_include_directories(shader_compiler PUBLIC ${PROJECT_SOURCE_DIR}/src/vendor/shaderc/third_party/glslang)
target_include_directories(shader_compiler PUBLIC ${PROJECT_SOURCE_DIR}/src/vendor/shaderc/third_party/effcee)
target_include_directories(shader_compiler PUBLIC ${PROJECT_SOURCE_DIR}/src/vendor/shaderc/third_party/re2)
target_include_directories(shader_compiler PUBLIC ${PROJECT_SOURCE_DIR}/src/vendor/shaderc/third_party/spirv-headers/include)
target_include_directories(shader_compiler PUBLIC ${PROJECT_SOURCE_DIR}/src/vendor/shaderc/third_party/spirv-tools/include)


target_include_directories(shader_compiler PUBLIC ${PROJECT_SOURCE_DIR}/src/vendor/json/single_include)

# setting c++ standard
set_target_properties(shader_compiler PROPERTIES
CXX_STANDARD 20
)

# setting c standard

set_target_properties(shader_compiler PROPERTIES
    C_STANDARD 20
)

add_library(shader_compiler_dynamic SHARED
    src/exports.cpp
)

target_link_libraries(shader_compiler_dynamic PRIVATE shader_compiler)

# setting c++ standard
set_target_properties(shader_compiler_dynamic PROPERTIES
    CXX_STANDARD 20
)

# setting c standard

set_target_properties(shader_compiler_dynamic PROPERTIES
    C_STANDARD 20
)





if(SHADER_COMPILER_RUN_TESTS)
  add_subdirectory(${PROJECT_SOURCE_DIR}/src/vendor/catch2)
  add_compile_definitions(__SHADER_COMPILER_TESTING__=1)

  list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/src/vendor/catch2/extras)

  include(CTest)
  include(Catch)

  add_executable(shader_compiler_tests 
    tests/shader_tests.cpp
  )

  set_target_properties(shader_compiler_tests PROPERTIES
      CXX_STANDARD 20
  )

  # setting c standard

  set_target_properties(shader_compiler_tests PROPERTIES
      C_STANDARD 20
  )

  target_link_libraries(shader_compiler_tests PRIVATE Catch2::Catch2WithMain)
  target_link_libraries(shader_compiler_tests PRIVATE shader_compiler)
  
  catch_discover_tests(shader_compiler_tests)

endif()