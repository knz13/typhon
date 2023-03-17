cmake_minimum_required(VERSION 3.16.0)

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
project(project_teste)

# --------------------- Repository declarations ------------------------
# repository download and settings for sol2...

  dir_exists(APPEND sol2_exists ${PROJECT_SOURCE_DIR}/vendor/sol2)

  if(NOT ${sol2}_exists)
    FetchContent_Declare(SOL2
        GIT_REPOSITORY https://github.com/ThePhD/sol2
        GIT_TAG origin/main
        SOURCE_DIR ${PROJECT_SOURCE_DIR}/vendor/sol2

    )   

    FetchContent_MakeAvailable(SOL2)
  endif()
    # includes for target typhon...

      list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/vendor/sol2/includes)

    # libraries for target typhon...

      list(APPEND typhon_LIBRARIES sol2)

# repository download and settings for lua...

  dir_exists(APPEND lua_exists ${PROJECT_SOURCE_DIR}/vendor/lua)

  if(NOT ${lua}_exists)
    FetchContent_Declare(LUA
        GIT_REPOSITORY https://github.com/marovira/lua
        GIT_TAG origin/master
        SOURCE_DIR ${PROJECT_SOURCE_DIR}/vendor/lua

    )   

    FetchContent_MakeAvailable(LUA)
  endif()
    # includes for target typhon...

      list(APPEND typhon_INCLUDES ${PROJECT_SOURCE_DIR}/vendor/lua/src)

    # libraries for target typhon...

      list(APPEND typhon_LIBRARIES lua::lua)



# --------------------- Targets ------------------------

  # settings for target typhon...

    # adding sources
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/typhon.cpp)
      list(APPEND typhon_SOURCE_FILES ${PROJECT_SOURCE_DIR}/src/lua.cpp)
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


