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

def compile(run_tests=False,release=False):

    is_64bits = sys.maxsize > 2**32

    os.system('echo "Creating shader compiler library!"')

    os.chdir("shader_compiler_library")

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



    os.system(' '.join(['cmake',"-DSHADER_COMPILER_RUN_TESTS=1",("-DCMAKE_BUILD_TYPE=" + ("Release" if release else "Debug")),("-DCMAKE_GENERATOR_PLATFORM=" + ("x64" if is_64bits else "x86")) if platform.system() != "Darwin" else "",'-S ./', '-B build']))

    os.system('echo "Finished CMake Proccess!"')

    os.chdir("build")

    os.system(f'{"make shader_compiler_dynamic" if platform.system() == "Darwin" else "msbuild project_shader_compiler_library.sln /target:shader_compiler_dynamic /p:Configuration=" + ("Release" if release else "Debug")}')

    os.system(f'{"make shader_compiler_tests" if platform.system() == "Darwin" else "msbuild project_shader_compiler_library.sln /target:shader_compiler_tests /p:Configuration=" + ("Release" if release else "Debug")}')

    os.system('echo "Finished Building Shader Compiler Library!"')

    os.system('echo "Moving Shader Compiler Library To Assets!"')

    if platform.system() == "Darwin":
        shutil.copy("libshader_compiler_dynamic.dylib","../../assets/lib/libshader_compiler_dynamic.dylib")
    else:
        shutil.copy(("Release" if release else "Debug") + "/" + "shader_compiler_dynamic.dll","../../assets/lib/shader_compiler_dynamic.dll")

        
    os.chdir('../../')


if __name__ == "__main__":

    compile(release=True)