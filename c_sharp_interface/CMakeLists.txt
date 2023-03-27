cmake_minimum_required(VERSION 3.16)

#adding useful functions

function(DIR_EXISTS variable dir_path)

file(GLOB ${variable}_check ${dir_path}/*)

list(LENGTH ${variable}_check ${variable}_len)

if(${${variable}_len} EQUAL 0)

set(${variable} FALSE PARENT_SCOPE)

else()

set(${variable} TRUE PARENT_SCOPE)

endif()

endfunction()

#adding extra cmake libs

include(GNUInstallDirs)
include(ExternalProject)
include(FetchContent)

#project name
project(project_typhon)

# --------------------- Repository declarations ------------------------
# repository download and settings for mono...


    #FetchContent_Declare(MONO
    #    GIT_REPOSITORY https://github.com/volcoma/monopp
    #    GIT_TAG origin/master
    #    SOURCE_DIR ${PROJECT_SOURCE_DIR}/vendor/mono
    #  
    #) 
    

    #FetchContent_MakeAvailable(MONO)
    # includes for target typhon...

      #list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/vendor/mono/)

    # libraries for target typhon...
    
   # list(APPEND typhon_LIBRARIES monopp)
    
    # repository download and settings for shaderc


# --------------------- Targets ------------------------

  # settings for target typhon...

    # adding sources
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/typhon.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/mono_manager.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/shader_compiler.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/gameobject.cpp)
    # creating target

    

    add_library(typhon SHARED

        ${typhon_SOURCE_FILES}
    )


    set(SHADERC_SKIP_TESTS ON)
    set(SHADERC_SKIP_EXAMPLES ON)
    
    add_subdirectory(${PROJECT_SOURCE_DIR}/vendor/shaderc)

    target_link_libraries(typhon PUBLIC shaderc)

    target_include_directories(typhon PUBLIC ${PROJECT_SOURCE_DIR}/vendor/shaderc/libshaderc/include)
    target_include_directories(typhon PUBLIC ${PROJECT_SOURCE_DIR}/vendor/shaderc/libshaderc/src)
    target_include_directories(typhon PUBLIC ${PROJECT_SOURCE_DIR}/vendor/shaderc/libshaderc_util/include)
    target_include_directories(typhon PUBLIC ${PROJECT_SOURCE_DIR}/vendor/shaderc/libshaderc_util/src)
    target_include_directories(typhon PUBLIC ${PROJECT_SOURCE_DIR}/vendor/shaderc/third_party/glslang)
    target_include_directories(typhon PUBLIC ${PROJECT_SOURCE_DIR}/vendor/shaderc/third_party/effcee)
    target_include_directories(typhon PUBLIC ${PROJECT_SOURCE_DIR}/vendor/shaderc/third_party/re2)
    target_include_directories(typhon PUBLIC ${PROJECT_SOURCE_DIR}/vendor/shaderc/third_party/spirv-headers/include)
    target_include_directories(typhon PUBLIC ${PROJECT_SOURCE_DIR}/vendor/shaderc/third_party/spirv-tools/include)
    


    # setting c++ standard
    set_target_properties(typhon PROPERTIES
        CXX_STANDARD 20
    )

    # setting c standard

    set_target_properties(typhon PROPERTIES
        C_STANDARD 20
    )
    # adding include paths 

      list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src)

      target_include_directories(typhon PUBLIC ${typhon_INCLUDES})

    # adding internal libraries

      target_link_libraries(typhon PUBLIC ${typhon_LIBRARIES})
    
    

