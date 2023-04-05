import sys
import subprocess
import platform
import argparse
import os
import subprocess
from glob import glob
import shutil


parser = argparse.ArgumentParser("create library")


parser.add_argument("--Release",action='store_true')


args = parser.parse_args()


is_64bits = sys.maxsize > 2**32

current_dir = os.path.abspath(os.curdir)
os.chdir("c_sharp_interface")
if not os.path.exists("vendor"):
    os.mkdir("vendor")


__subdirectories = glob("src/*/", recursive = True)

__subdirectories = list(map(lambda x: list(map(lambda y: x + y,os.listdir(x))),__subdirectories))

subdirectories_items = []
for item in __subdirectories:
    subdirectories_items += item

subdirectories_items = list(map(lambda x: (x[x.rfind("/") + 1:-2],x[4:]),filter(lambda x: x.endswith(".h") ,subdirectories_items)))

print(subdirectories_items)

with open("src/typhon.cpp",'r') as f:

    final_file_data = """/*
GENERATED FILE - DO NOT MODIFY!
*/
"""
    for line in f.readlines():
        if "// -- INCLUDE CREATED CLASSES -- //" in line:
            for klass,dir in subdirectories_items:
                final_file_data += f'#include "{dir}"\n'
        elif "// -- INITIALIZE EACH OBJECT -- //" in line:
            for klass,dir in subdirectories_items:
                final_file_data += f'    {klass}();\n'
        else:
            final_file_data += line
            
    with open("src/typhon_generated.cpp",'w') as g:
        g.write(final_file_data)

os.system('echo "written typhon_generated.cpp"')


if not os.path.exists("vendor/shaderc"):
    os.system('echo downloading shaderc library...')
    os.system("git clone https://github.com/google/shaderc vendor/shaderc")
    os.system(("python " if platform.system() != "Darwin" else "") + "vendor/shaderc/utils/git-sync-deps")

os.system('echo "Creating c++ library..."')
os.system(f'cmake {("-DCMAKE_BUILD_TYPE=" + ("Release" if args.Release else "Debug")) if platform.system() == "Darwin" else ("-DCMAKE_GENERATOR_PLATFORM=" + ("x64" if is_64bits else "x86"))} -B build ./ ')
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
    
os.chdir(os.path.join(current_dir,"c_sharp_interface"))

if(os.path.exists(os.path.join(current_dir,"assets/lib/include"))):
    for file in os.listdir(os.path.join(current_dir,"assets/lib/include")):
        os.remove(os.path.join(current_dir,"assets/lib/include",file))

for file in os.listdir('src'):
    if file.endswith(".h"):
        shutil.copyfile(os.path.join("src",file),os.path.join("../assets/lib/includes",file))



os.system('echo "Build finished!"')

os.system('echo "Updating dart bindings file..."')

os.system(f'cd {current_dir} && dart run ffigen --config ffigen.yaml')

os.system('echo "Done updating dart bindings file!"')