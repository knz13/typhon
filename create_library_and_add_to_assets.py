import subprocess
import platform
import argparse
import os


parser = argparse.ArgumentParser("create library")


parser.add_argument("--Release",action='store_true')


args = parser.parse_args()

os.chdir("lua_binding_library")
os.system('echo "Creating c++ library..."')
os.system(f'cmake {"-DCMAKE_BUILD_TYPE=" + ("Release" if args.Release else "Debug") if platform.system() == "Darwin" else ""} -B build ./')
os.system('echo "CMake run finished!')
os.system('echo "Compiling..."')
os.system(f'cd build && {"make" if platform.system() == "Darwin" else "msbuild project_typhon /p:Configuration=" + "Release" if args.Release else "Debug"}')
os.system('echo "Moving library to assets..."')
os.system(f'cd build && {"mv libtyphon.dylib ../../assets/lib/libtyphon.dylib" if platform.system() == "Darwin" else "MOVE "}')
os.system('echo "Build finished!"')