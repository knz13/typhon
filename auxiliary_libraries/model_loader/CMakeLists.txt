cmake_minimum_required(VERSION 3.16)

#adding extra cmake libs

include(ExternalProject)
include(FetchContent)


#project name
project(project_model_loader_library)

option(SHADER_COMPILER_RUN_TESTS "Run Tests" OFF)

#model_loader definition
add_library(model_loader SHARED
    model_loader.cpp
    exports.cpp
)



#ASSIMP setup

set(ASSIMP_BUILD_TESTS OFF)
set(ASSIMP_INSTALL OFF)
set(ASSIMP_INJECT_DEBUG_POSTFIX OFF)
set(ASSIMP_BUILD_SHARED_LIBS OFF)


add_subdirectory(${PROJECT_SOURCE_DIR}/vendor/assimp)

set(CMAKE_DEBUG_POSTFIX "")

# setting c++ standard
set_target_properties(model_loader PROPERTIES
    CXX_STANDARD 20
)



# setting c standard

set_target_properties(model_loader PROPERTIES
    C_STANDARD 20
)




target_include_directories(model_loader PRIVATE ${PROJECT_SOURCE_DIR}/vendor/assimp/include)
target_include_directories(model_loader PRIVATE ${PROJECT_SOURCE_DIR}/build/vendor/assimp/include/)
target_link_libraries(model_loader PRIVATE assimp)




