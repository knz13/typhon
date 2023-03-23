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

  dir_exists(APPEND mono_exists ${PROJECT_SOURCE_DIR}/vendor/mono)

  if(NOT ${mono}_exists)
    FetchContent_Declare(MONO
        GIT_REPOSITORY https://github.com/volcoma/monopp
        GIT_TAG origin/master
        SOURCE_DIR ${PROJECT_SOURCE_DIR}/vendor/mono

    )   

    FetchContent_MakeAvailable(MONO)
  endif()
    # includes for target typhon...

      list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/vendor/mono/)

    # libraries for target typhon...

      list(APPEND typhon_LIBRARIES monopp)



# --------------------- Targets ------------------------

  # settings for target typhon...

    # adding sources
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/typhon.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/mono_manager.cpp)
    # creating target

    add_library(typhon SHARED

        ${typhon_SOURCE_FILES}
    )

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


