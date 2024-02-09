cmake_minimum_required(VERSION 3.16)
#project name
project(typhon)

if(APPLE)
enable_language(OBJC)
endif()

add_subdirectory("cpp_library")
