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

def compile_auxiliary_libraries(run_tests=False,release=False):

    is_64bits = sys.maxsize > 2**32

    os.system('echo Creating shader compiler library!')

    if platform.system() != "Darwin":
        os.system('echo Installing Ninja build system!')
        os.system("pip install ninja")

    os.chdir("auxiliary_libraries")

    if not os.path.exists("src/vendor"):
        os.mkdir("src/vendor")

    #downloading dependencies
    if not os.path.exists("src/vendor/shaderc"):
        os.system('echo downloading shaderc library...')
        os.system("git clone https://github.com/google/shaderc src/vendor/shaderc")
        os.system(("python " if platform.system() != "Darwin" else "") + "src/vendor/shaderc/utils/git-sync-deps")

    if not os.path.exists("src/vendor/spirv_cross"):
        os.system('git clone --recursive https://github.com/KhronosGroup/SPIRV-Cross src/vendor/spirv_cross')

    if not os.path.exists("src/vendor/json"):
        os.system('git clone --recursive https://github.com/nlohmann/json src/vendor/json')    

    if run_tests:
        if not os.path.exists("src/vendor/catch2"):
            os.system('git clone --recursive https://github.com/catchorg/Catch2 src/vendor/catch2')

    cmake_command = ("src/vendor/cmake/cmake-3.26.3-macos-universal/CMake.app/Contents/bin/cmake" if platform.system() == "Darwin" else "src/vendor/cmake/cmake-3.26.3-windows-x86_64/bin/cmake.exe") if shutil.which("cmake") is None else "cmake"

    os.system(' '.join([cmake_command,"-DSHADER_COMPILER_RUN_TESTS=0",("-DCMAKE_BUILD_TYPE=" + ("Release" if release else "Debug")),("-G Ninja") if platform.system() != "Darwin" else "",'-S ./', '-B build']))

    os.system('echo Finished CMake Proccess!')

    os.chdir("build")
    
    os.system('echo Building Auxiliary Library!')
    os.system(f'{"make typhon_auxiliary_dynamic" if platform.system() == "Darwin" else "ninja"}')
    if run_tests:
        os.system(f'{"make shader_compiler_tests" if platform.system() == "Darwin" else "msbuild project_typhon_auxiliary_libraries.sln /target:shader_compiler_tests /p:Configuration=" + ("Release" if release else "Debug")}')

    os.system('echo Finished Building Auxiliary Library!')

    os.system('echo Moving Auxiliary Libraries To Assets!')

    if platform.system() == "Darwin":
        shutil.copy("libtyphon_auxiliary_dynamic.dylib","../../assets/lib/libtyphon_auxiliary_dynamic.dylib")
    else:
        shutil.copy("libtyphon_auxiliary_dynamic.dll","../../assets/lib/typhon_auxiliary_dynamic.dll")

    os.system('echo Finished Moving Auxiliary Library To Assets!')
        
    os.chdir('../../')


if __name__ == "__main__":


    compile(release=True)