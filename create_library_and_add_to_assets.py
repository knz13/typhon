import sys
import subprocess
import platform
import argparse
import os
import subprocess
from glob import glob
import shutil
from subprocess import check_output

parser = argparse.ArgumentParser("create library")


parser.add_argument("--Release",action='store_true')


args = parser.parse_args()


is_64bits = sys.maxsize > 2**32

current_dir = os.path.abspath(os.curdir)
os.chdir("c_sharp_interface")
if not os.path.exists("src/vendor"):
    os.mkdir("src/vendor")




#downloading dependencies
if not os.path.exists("src/vendor/shaderc"):
    os.system('echo downloading shaderc library...')
    os.system("git clone https://github.com/google/shaderc src/vendor/shaderc")
    os.system(("python " if platform.system() != "Darwin" else "") + "src/vendor/shaderc/utils/git-sync-deps")

if not os.path.exists("src/vendor/catch2"):
    os.system('git clone --recursive https://github.com/catchorg/Catch2 src/vendor/catch2')
if not os.path.exists("src/vendor/ecspp"):
    os.system('git clone --recursive https://github.com/knz13/ecspp src/vendor/ecspp')
if not os.path.exists("src/vendor/yael"):
    os.system('git clone --recursive https://github.com/knz13/YAEL src/vendor/yael')
if not os.path.exists("src/vendor/random"):
    os.system('git clone --recursive https://github.com/effolkronium/random src/vendor/random')
if not os.path.exists("src/vendor/glm"):
    os.system('git clone --recursive https://github.com/g-truc/glm src/vendor/glm')
if not os.path.exists("src/vendor/crunch"):
    os.system('git clone --recursive https://github.com/johnfredcee/crunch src/vendor/crunch')
if not os.path.exists("src/vendor/json"):
    os.system('git clone --recursive https://github.com/nlohmann/json src/vendor/json')


os.system(' '.join(['cmake', '-DTYPHON_RUN_TESTS=ON',("-DCMAKE_BUILD_TYPE=" + ("Release" if args.Release else "Debug")),("-DCMAKE_GENERATOR_PLATFORM=" + ("x64" if is_64bits else "x86")) if platform.system() != "Darwin" else "",'-S ./', '-B build']))

roots = []
os.makedirs("../assets/lib",exist_ok=True)
shutil.copyfile("CMakeLists.txt","../assets/lib/CMakeLists.txt")
dir = os.listdir("src")
for root, dirs, files in os.walk('src'):
    root = os.path.abspath(root)
    if os.path.basename(root).startswith("."):
        continue
    for file in files:
        if file in dir or os.path.relpath(os.path.abspath(os.path.join(root,file)),os.path.abspath("src/vendor/")).count("..") == 0:
            if os.path.basename(root).startswith("."):
                continue
            if not os.path.exists(os.path.join("../assets/lib/src",os.path.relpath(root,os.path.join(current_dir,"c_sharp_interface","src")))):
                os.makedirs(os.path.join("../assets/lib/src/",os.path.relpath(root,os.path.join(current_dir,"c_sharp_interface","src"))),exist_ok=True)
            if root not in roots:
                roots.append(root)
            shutil.copyfile(os.path.join(root,file),os.path.join("../assets/lib/src",os.path.relpath(root,os.path.join(current_dir,"c_sharp_interface","src")),file))
    #print(f"Done dir {root}")

paths_to_add_to_pubspec = []
for root in roots:
    path = os.path.relpath(root,os.path.join(current_dir,"c_sharp_interface","src")).replace("\\","/")
    paths_to_add_to_pubspec.append(f'    - assets/lib/src/{path}/')

os.chdir(current_dir)

pubspecNew = ""
with open("pubspec.yaml",'r') as f:
    lines = f.readlines()
    shouldStartIncluding = False

    for line in lines:
        if "__BEGIN__ASSETS__INCLUSION__" in line:
            pubspecNew += line
            shouldStartIncluding = True
        
        if "__END__ASSETS__INCLUSION__" in line:
            pubspecNew += "\n".join(paths_to_add_to_pubspec) + "\n"
            pubspecNew += line
            shouldStartIncluding = False
            continue


        if shouldStartIncluding:
            continue

        pubspecNew += line

with open("pubspec.yaml",'w') as f:
    f.write(pubspecNew)

cpp_exports = ""
cpp_exports_impl = ""

os.chdir(current_dir)
with open("c_sharp_interface/src/typhon.h",'r') as f:
    lines = f.readlines()
    shouldAddLine = False
    for line in lines:
        if "//__BEGIN__CPP__EXPORTS__" in line:
            shouldAddLine = True
            continue
        if "//__END__CPP__EXPORTS__" in line:
            shouldAddLine = False
            break
        if shouldAddLine:
            cpp_exports += line + "\n"

with open("c_sharp_interface/src/typhon.cpp",'r') as f:
    lines = f.readlines()
    shouldAddLine = False
    for line in lines:
        if "//__BEGIN__CPP__IMPL__" in line:
            shouldAddLine = True
            continue
        if "//__END__CPP__IMPL__" in line:
            shouldAddLine = False
            break
        if shouldAddLine:
            cpp_exports_impl += line + "\n"

engine_new_code = ""
with open("lib/engine.dart",'r') as f:
    lines = f.readlines()
    foundCppExportsLine = False
    foundCppExportsImplLine = False

    for line in lines:
        if "//__BEGIN__CPP__EXPORTS__" in line:
            foundCppExportsLine = True
            engine_new_code += line
        if "//__BEGIN__CPP__IMPL__" in line:
            foundCppExportsImplLine = True
            engine_new_code += line
        if "//__END__CPP__EXPORTS__" in line:
            foundCppExportsLine = False
            engine_new_code += cpp_exports
            engine_new_code += "//__END__CPP__EXPORTS__\n"
            continue
        if "//__END__CPP__IMPL__" in line:
            foundCppExportsImplLine = False
            engine_new_code += cpp_exports_impl
            engine_new_code += "//__END__CPP__IMPL__\n"
            continue

        if foundCppExportsImplLine or foundCppExportsLine:
            continue

        engine_new_code += line
        
with open("lib/engine.dart",'w') as f:
    f.write(engine_new_code)


os.system('echo "Updating dart bindings file..."')

os.system(f'dart run ffigen --config ffigen.yaml')

os.system('echo "Done updating dart bindings file!"')

os.system('echo "Building tests...')


os.chdir("c_sharp_interface/build")

os.system(f'{"make typhon_tests" if platform.system() == "Darwin" else "msbuild project_typhon.sln /target:typhon_tests /p:Configuration=" + ("Release" if args.Release else "Debug")}')

os.system('echo "Build finished!"')

os.system('echo "Running tests"')

if platform.system() == "Darwin":
    subprocess.call(["open","typhon_tests"])
else:
    subprocess.call(["Debug/typhon_tests.exe"])
    