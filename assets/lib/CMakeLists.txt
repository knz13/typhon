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

set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

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

    
    FetchContent_Declare(ENTT
        GIT_REPOSITORY https://github.com/skypjack/entt
        GIT_TAG v3.11.1
        SOURCE_DIR ${PROJECT_SOURCE_DIR}/src/vendor/entt
    ) 
    

    FetchContent_MakeAvailable(ENTT)
    #includes for target typhon...
    
    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/entt/src/)
    
    FetchContent_Declare(YAEL
    GIT_REPOSITORY https://github.com/knz13/YAEL
    GIT_TAG origin/main
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/src/vendor/yael
    ) 
    
    
    FetchContent_MakeAvailable(YAEL)
    
    
    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/yael/include)
    
    FetchContent_Declare(RANDOM
    GIT_REPOSITORY https://github.com/effolkronium/random
    GIT_TAG v1.4.1
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/src/vendor/random
    ) 
    
    
    FetchContent_MakeAvailable(RANDOM)
    
    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/random/include)
    
    FetchContent_Declare(GLM
    GIT_REPOSITORY https://github.com/g-truc/glm
    GIT_TAG 0.9.9.8
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/src/vendor/glm
    ) 
    
    
    FetchContent_MakeAvailable(GLM)
    
    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/glm/)
    
    FetchContent_Declare(CRUNCH
    GIT_REPOSITORY https://github.com/johnfredcee/crunch
    GIT_TAG origin/master
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/src/vendor/crunch
    )

    FetchContent_MakeAvailable(CRUNCH)

    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/crunch/crunch/)
    list(APPEND typhon_LIBRARIES libcrunch)


    FetchContent_Declare(JSON
    GIT_REPOSITORY https://github.com/nlohmann/json
    GIT_TAG v3.11.2
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/src/vendor/json
    ) 

    FetchContent_MakeAvailable(JSON)

    list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/src/vendor/json/single_include)
    
    
    # --------------------- Targets ------------------------

  # settings for target typhon...

    # adding sources
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/mono_manager.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/shader_compiler.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/engine.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/general.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/game_object.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/ecs_registry.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/game_object_traits.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/generic_reflection.cpp)
    # creating target


    add_library(typhon SHARED

        ${typhon_SOURCE_FILES}
    )


    set(SHADERC_SKIP_TESTS ON)
    set(SHADERC_SKIP_EXAMPLES ON)
    
    add_subdirectory(${PROJECT_SOURCE_DIR}/src/vendor/shaderc)

    target_link_libraries(typhon PUBLIC shaderc)
    
    target_include_directories(typhon PUBLIC ${PROJECT_SOURCE_DIR}/src/vendor/shaderc/libshaderc/include)
    target_include_directories(typhon PUBLIC ${PROJECT_SOURCE_DIR}/src/vendor/shaderc/libshaderc/src)
    target_include_directories(typhon PUBLIC ${PROJECT_SOURCE_DIR}/src/vendor/shaderc/libshaderc_util/include)
    target_include_directories(typhon PUBLIC ${PROJECT_SOURCE_DIR}/src/vendor/shaderc/libshaderc_util/src)
    target_include_directories(typhon PUBLIC ${PROJECT_SOURCE_DIR}/src/vendor/shaderc/third_party/glslang)
    target_include_directories(typhon PUBLIC ${PROJECT_SOURCE_DIR}/src/vendor/shaderc/third_party/effcee)
    target_include_directories(typhon PUBLIC ${PROJECT_SOURCE_DIR}/src/vendor/shaderc/third_party/re2)
    target_include_directories(typhon PUBLIC ${PROJECT_SOURCE_DIR}/src/vendor/shaderc/third_party/spirv-headers/include)
    target_include_directories(typhon PUBLIC ${PROJECT_SOURCE_DIR}/src/vendor/shaderc/third_party/spirv-tools/include)

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
      
      get_target_property(TYPHON_INCLUDES_FINAL typhon INCLUDE_DIRECTORIES)
        
      foreach(X IN LISTS TYPHON_INCLUDES_FINAL)
        message(STATUS "target_include_directories(SOMETHING PUBLIC ${X})")
      endforeach()
      
      message(STATUS "BEGIN__INCLUDE__DIRS ${TYPHON_INCLUDES_FINAL};${} END__INCLUDE__DIRS")
    

