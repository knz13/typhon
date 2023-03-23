import subprocess
import platform
import argparse
import os
import subprocess


parser = argparse.ArgumentParser("create library")


parser.add_argument("--Release",action='store_true')


args = parser.parse_args()

os.chdir("c_sharp_interface")
os.system('echo "Creating c++ library..."')
os.system(f'cmake {"-DCMAKE_BUILD_TYPE=" + ("Release" if args.Release else "Debug") if platform.system() == "Darwin" else ""} -B build ./')
os.system('echo "CMake run finished!')
os.system('echo "Compiling..."')
os.chdir("build")
os.system(f'{"make" if platform.system() == "Darwin" else "msbuild project_typhon.sln /p:Configuration=" + ("Release" if args.Release else "Debug")}')
os.system('echo "Moving library to assets..."')

if platform.system() == "Darwin":
    os.rename(os.path.abspath("libtyphon.dylib"),os.path.abspath("../../assets/lib/libtyphon.dylib"))
else:
    os.rename(os.path.abspath("Debug/typhon.dll" if not args.Release else "Release/typhon.dll"),os.path.abspath("../../assets/lib/typhon.dll"))
    

os.system('echo "Build finished!"')

os.system('echo "Updating dart bindings file..."')

os.system('cd ../../ && dart run ffigen --config ffigen.yaml')

os.system('echo "Done updating dart bindings file!"')