import subprocess
import platform
import argparse
import os
import subprocess


parser = argparse.ArgumentParser("create library")


parser.add_argument("--Release",action='store_true')


args = parser.parse_args()

current_dir = os.path.abspath(os.curdir)
os.chdir("c_sharp_interface")
if not os.path.exists("vendor"):
    os.mkdir("vendor")

if not os.path.exists("vendor/shaderc"):
    os.system('echo downloading shaderc library...')
    os.system("git clone https://github.com/google/shaderc vendor/shaderc")
    os.system(("python " if platform.system() != "Darwin" else "") + "vendor/shaderc/utils/git-sync-deps")

os.system('echo "Creating c++ library..."')
os.system(f'cmake {"-DCMAKE_BUILD_TYPE=" + ("Release" if args.Release else "Debug") if platform.system() == "Darwin" else ""} -B build ./')
os.system('echo "CMake run finished!')
os.system('echo "Compiling..."')
os.chdir("build")
os.system(f'{"make" if platform.system() == "Darwin" else "msbuild project_typhon.sln /p:Configuration=" + ("Release" if args.Release else "Debug")}')
os.system('echo "Moving library to assets..."')

if platform.system() == "Darwin":
    if os.path.exists(os.path.abspath("../../assets/lib/libtyphon.dylib")):
        os.remove(os.path.abspath("../../assets/lib/libtyphon.dylib"))
    os.rename(os.path.abspath("libtyphon.dylib"),os.path.abspath("../../assets/lib/libtyphon.dylib"))
else:
    if os.path.exists(os.path.abspath("../../assets/lib/typhon.dll")):
        os.remove(os.path.abspath("../../assets/lib/typhon.dll"))
    os.rename(os.path.abspath("Debug/typhon.dll" if not args.Release else "Release/typhon.dll"),os.path.abspath("../../assets/lib/typhon.dll"))
    

os.system('echo "Build finished!"')

os.system('echo "Updating dart bindings file..."')

os.system('cd ../../ && dart run ffigen --config ffigen.yaml')

os.system('echo "Done updating dart bindings file!"')