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

    os.system('echo Creating Model Loader Library!')

    if not os.path.exists("vendor"):
        os.mkdir("vendor")

    #downloading dependencies
    
    
    if not os.path.exists("vendor/assimp"):
        os.system('git clone --recursive https://github.com/assimp/assimp vendor/assimp')    

    if run_tests:
        if not os.path.exists("vendor/catch2"):
            os.system('git clone --recursive https://github.com/catchorg/Catch2 vendor/catch2')

    cmake_command = ("vendor/cmake/cmake-3.26.3-macos-universal/CMake.app/Contents/bin/cmake" if platform.system() == "Darwin" else "vendor/cmake/cmake-3.26.3-windows-x86_64/bin/cmake.exe") if shutil.which("cmake") is None else "cmake"

    os.system(' '.join([cmake_command,"-DSHADER_COMPILER_RUN_TESTS=0",("-DCMAKE_BUILD_TYPE=" + ("Release" if release else "Debug")),("-G Ninja") if platform.system() != "Darwin" else "",'-S ./', '-B build']))

    os.system('echo Finished CMake Proccess!')

    os.chdir("build")
    
    os.system('echo Building Model Loader Library!')
    os.system(f'{"make model_loader" if platform.system() == "Darwin" else "ninja"}')
    if run_tests:
        os.system(f'{"make model_loader_tests" if platform.system() == "Darwin" else "msbuild project_model_loader_library.sln /target:model_loader_tests /p:Configuration=" + ("Release" if release else "Debug")}')

    os.system('echo Finished Building Model Loader Library!')

    os.system('echo Moving Model Loader Library To Assets!')

    if not os.path.exists("../../../assets/lib/auxiliary_libraries"):
        os.mkdir("../../../assets/lib/auxiliary_libraries")
    
    if platform.system() == "Darwin":
        shutil.copy("libmodel_loader.dylib","../../../assets/lib/auxiliary_libraries/libmodel_loader.dylib")
    else:
        shutil.copy("libmodel_loader.dll","../../../assets/lib/auxiliary_libraries/model_loader.dll")

    os.system('echo Finished Moving Model Loader Library To Assets!')

    os.chdir("../")
        