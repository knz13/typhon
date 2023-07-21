import sys
import subprocess
import platform
import argparse
import os
import subprocess
from glob import glob
import shutil
import re
from subprocess import check_output

def create_library(run_tests=False,release=False):

    os.system('echo Creating Shader Compiler Library!')

    if not os.path.exists("vendor"):
        os.mkdir("vendor")

    #downloading dependencies
    if not os.path.exists("vendor/shaderc"):
        os.system('echo downloading shaderc library...')
        os.system("git clone https://github.com/google/shaderc vendor/shaderc")
        os.system(("python " if platform.system() != "Darwin" else "") + "vendor/shaderc/utils/git-sync-deps")

    if not os.path.exists("vendor/spirv_cross"):
        os.system('git clone --recursive https://github.com/KhronosGroup/SPIRV-Cross vendor/spirv_cross')

    if not os.path.exists("vendor/json"):
        os.system('git clone --recursive https://github.com/nlohmann/json vendor/json')    
  

    if run_tests:
        if not os.path.exists("vendor/catch2"):
            os.system('git clone --recursive https://github.com/catchorg/Catch2 vendor/catch2')

    cmake_command = ("vendor/cmake/cmake-3.26.3-macos-universal/CMake.app/Contents/bin/cmake" if platform.system() == "Darwin" else "vendor/cmake/cmake-3.26.3-windows-x86_64/bin/cmake.exe") if shutil.which("cmake") is None else "cmake"

    os.system(' '.join([cmake_command,"-DSHADER_COMPILER_RUN_TESTS=0",("-DCMAKE_BUILD_TYPE=" + ("Release" if release else "Debug")),("-G Ninja") if platform.system() != "Darwin" else "",'-S ./', '-B build']))

    os.system('echo Finished CMake Proccess!')

    os.chdir("build")
    
    os.system('echo Building Shader Compiler Library!')
    os.system(f'{"make shader_compiler" if platform.system() == "Darwin" else "ninja"}')
    if run_tests:
        os.system(f'{"make shader_compiler_tests" if platform.system() == "Darwin" else "msbuild project_shader_compiler_library.sln /target:shader_compiler_tests /p:Configuration=" + ("Release" if release else "Debug")}')

    os.system('echo Finished Building Shader Compiler Library!')

    os.system('echo Moving Auxiliary Libraries To Assets!')

    if not os.path.exists("../../../assets/lib/auxiliary_libraries"):
        os.mkdir("../../../assets/lib/auxiliary_libraries")
    
    if platform.system() == "Darwin":
        shutil.copy("libshader_compiler.dylib","../../../assets/lib/auxiliary_libraries/libshader_compiler.dylib")
    else:
        shutil.copy("libshader_compiler.dll","../../../assets/lib/auxiliary_libraries/shader_compiler.dll")

    os.system('echo Finished Moving Shader Compiler Library To Assets!')
        
    os.chdir("../")