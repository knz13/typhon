import sys
import subprocess
import platform
import argparse
import os
import subprocess
from glob import glob
import shutil
import re
from io import BytesIO
from urllib.request import urlopen
from zipfile import ZipFile
import tarfile
from subprocess import check_output
import requests
from python_scripts.cpp_parser import CPPParser
import distutils.dir_util

def get_first_available_cpp_compiler():
    system = platform.system()
    if system == 'Darwin':
        compilers = ['clang++', 'c++', 'g++', 'xcrun', 'icc', 'icpc']
    elif system == 'Windows':
        compilers = ['clang++', 'cl.exe', 'g++', 'c++', 'icc', 'icpc']
    else:
        compilers = ['clang++', 'g++', 'c++', 'icc', 'icpc']

    for compiler in compilers:
        if shutil.which(compiler) is not None:
            return compiler

    return None

def download_and_extract(url,save_location):
    
    if url.endswith(".zip"):
        with urlopen(url) as zipresp:
            with ZipFile(BytesIO(zipresp.read())) as zfile:
                zfile.extractall(save_location)
        return
    if url.endswith(".gz"):
        response = requests.get(url, stream=True)
        file = tarfile.open(fileobj=response.raw, mode="r|gz")
        file.extractall(path=save_location)
        return
            
    raise ValueError("Url is not related to a zip file!")



parser = argparse.ArgumentParser("create library")


parser.add_argument("--Release",action='store_true')
parser.add_argument("--run-tests",action='store_true')

args = parser.parse_args()



if shutil.which("cmake") is None:
    if platform.system() == "Darwin":
        #only for macos and windows x64
        download_and_extract("https://github.com/Kitware/CMake/releases/download/v3.26.3/cmake-3.26.3-macos-universal.tar.gz","src/vendor/cmake")
    else:
        download_and_extract("https://github.com/Kitware/CMake/releases/download/v3.26.3/cmake-3.26.3-windows-x86_64.zip","src/vendor/cmake")


cmake_command = ("src/vendor/cmake/cmake-3.26.3-macos-universal/CMake.app/Contents/bin/cmake" if platform.system() == "Darwin" else "src/vendor/cmake/cmake-3.26.3-windows-x86_64/bin/cmake.exe") if shutil.which("cmake") is None else "cmake"


import create_auxiliary_libraries as shader_lib

shader_lib.compile_auxiliary_libraries(run_tests=args.run_tests,release=False)



is_64bits = sys.maxsize > 2**32

current_dir = os.path.abspath(os.curdir)


os.chdir("cpp_library")
if not os.path.exists("src/vendor"):
    os.mkdir("src/vendor")



#downloading dependencies

#if get_first_available_cpp_compiler() == None:



if not os.path.exists("src/vendor/dylib"):
    os.system('git clone --recursive https://github.com/martin-olivier/dylib src/vendor/dylib')
if not os.path.exists("src/vendor/entt"):
    os.system('git clone --recursive https://github.com/skypjack/entt src/vendor/entt')
if not os.path.exists("src/vendor/yael"):
    os.system('git clone --recursive https://github.com/knz13/YAEL src/vendor/yael')
if not os.path.exists("src/vendor/random"):
    os.system('git clone --recursive https://github.com/effolkronium/random src/vendor/random')
if not os.path.exists("src/vendor/glm"):
    os.system('git clone --recursive https://github.com/g-truc/glm src/vendor/glm')
if not os.path.exists("src/vendor/json"):
    os.system('git clone --recursive https://github.com/nlohmann/json src/vendor/json')
if not os.path.exists("src/vendor/igl"):
        os.system('git clone --recursive https://github.com/facebook/igl/ src/vendor/igl')    
if not os.path.exists("src/vendor/crunch"):
    os.system('git clone --recursive https://github.com/johnfredcee/crunch src/vendor/crunch')

    for file in os.listdir("src/vendor/crunch/crunch"):
        with open(f'src/vendor/crunch/crunch/{file}','r', encoding='iso-8859-1') as f:
            file_data = f.read()
        
        if file != "packer.hpp":
            pattern = r'(?<![A-Za-z<>])Point(?![A-Za-z<>])'
            file_data = re.sub(pattern, 'Crunch::Point', file_data)
        else:
            file_data = file_data.replace("""struct Point
{
    int x;
    int y;
    int dupID;
    bool rot;
};""","""
namespace Crunch {

    struct Point
    {
        int x;
        int y;
        int dupID;
        bool rot;
    };

}
""")        
            file_data = file_data.replace("vector<Point> points;","vector<Crunch::Point> points;")

        with open(f'src/vendor/crunch/crunch/{file}','w') as f:
            f.write(file_data)
        



if platform.system() == "Darwin":
    if not os.path.exists("src/vendor/metal-cpp"):
        os.system('git clone --recursive https://github.com/LeeTeng2001/metal-cpp-cmake src/vendor/metal-cpp')
        for file in os.listdir('src/vendor/metal-cpp'):
            if file != "metal-cmake":
                os.system(f'rm -rf src/vendor/metal-cpp/{file}')

        shutil.copytree("src/vendor/metal-cpp/metal-cmake",'src/vendor/metal-cpp/',dirs_exist_ok=True)
        os.system("rm -rf src/vendor/metal-cpp/metal-cmake")

        with open("src/vendor/metal-cpp/CMakeLists.txt",'w') as f:
            f.write("""# Library definition
add_library(METAL_CPP
        ${CMAKE_CURRENT_SOURCE_DIR}/defination.cpp
        )

set_target_properties(METAL_CPP PROPERTIES
    CXX_STANDARD 20
)

# setting c standard

set_target_properties(METAL_CPP PROPERTIES
    C_STANDARD 20
)

# Metal cpp headers
target_include_directories(METAL_CPP PUBLIC
        "${CMAKE_CURRENT_SOURCE_DIR}/metal-cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/metal-cpp-extensions"
        )

# Metal cpp library (linker)
target_link_libraries(METAL_CPP
        "-framework Metal"
        "-framework MetalKit"
        "-framework AppKit"
        "-framework Foundation"
        "-framework QuartzCore"
        )
""")

os.system("echo Running CMake Configuration for Main Library!")
os.system(' '.join([cmake_command, '-DTYPHON_RUN_TESTS=OFF',("-DCMAKE_BUILD_TYPE=" + ("Release" if args.Release else "Debug")),("-G Ninja") if platform.system() != "Darwin" else "",'-S ./', '-B build']))
os.system("echo Finished Running CMake Configuration for Main Library!")

os.chdir(os.path.join(current_dir,"cpp_library","build"))
os.system("echo Building Typhon Library!")
os.system(f'{"make typhon" if platform.system() == "Darwin" else "ninja"}')
os.system("echo Built Typhon Library!")
os.chdir(os.path.join(current_dir,"cpp_library"))

roots = []
os.makedirs("../assets/lib",exist_ok=True)
shutil.copyfile("CMakeLists.txt","../assets/lib/CMakeLists.txt")
dir = os.listdir("src")
num_files = 0
for root, dirs, files in os.walk('src'):
    root = os.path.abspath(root)
    if os.path.basename(root).startswith("."):
        continue
    for file in files:
        if os.path.basename(root).startswith("."):
            continue
        if not os.path.exists(os.path.join("../assets/lib/src",os.path.relpath(root,os.path.join(current_dir,"cpp_library","src")))):
            os.makedirs(os.path.join("../assets/lib/src/",os.path.relpath(root,os.path.join(current_dir,"cpp_library","src"))),exist_ok=True)
        if root not in roots:
            roots.append(root)
        num_files += 1
            
    #print(f"Done dir {root}")

os.chdir(current_dir)

print("Copying Files To Assets!")

os.chdir("cpp_library")

distutils.dir_util.copy_tree(
    "src",
    os.path.join("../assets","lib",'src'),
    update=1,
    verbose=1,
)

print("Finished Copying Files To Assets!")

paths_to_add_to_pubspec = []
for root in roots:
    path = os.path.relpath(root,os.path.join(current_dir,"cpp_library","src")).replace("\\","/")
    paths_to_add_to_pubspec.append(f'    - assets/lib/src/{path}/')



os.chdir(current_dir)

for file in os.listdir("assets/lib/auxiliary_libraries"):
    paths_to_add_to_pubspec.append(f'    - assets/lib/auxiliary_libraries/{file}')

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
with open("cpp_library/src/typhon.h",'r') as f:
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


classes_found = {}
classes_to_check = []
for root, dirs, files in os.walk("cpp_library/src"):
    if "vendor" in root:
        continue
    for file in files:
        file_path = os.path.join(root, file).replace(r"\\","/").replace("\\","/")
        try:
            with open(file_path, 'r') as f:
                value = f.read()
            classes = CPPParser.get_classes_properties(value)
            for klass in classes:
                classes[klass]["path"] = os.path.relpath(file_path,"cpp_library/src")
                classes_found[klass] = classes[klass]
                if "IsInitializedStatically" in classes[klass]['inheritance']:
                    classes_to_check.append(klass)
                if "Reflection::IsInitializedStatically" in classes[klass]['inheritance']:
                    classes_to_check.append(klass)
                
        except Exception as e:
            print(f"Couldn't open {file_path}: {e}")

classes_to_initialize = []
while len(classes_to_check) > 0:
    classes_to_check_next = []
    for klass in classes_to_check:
        if not classes_found[klass]['templated']:
            classes_to_initialize.append((klass,classes_found[klass]['path']))
        else:
            classes_to_check_next.append(klass)
    classes_to_check.clear()
    for klass in classes_found:
        for klass_templated in classes_to_check_next:
            if klass_templated in classes_found[klass]['inheritance']:
                classes_to_check.append(klass)


print(f'CLASSES TO INITIALIZE: {classes_to_initialize}')

with open("cpp_library/src/typhon.cpp",'r') as f:
    lines = f.readlines()
    shouldAddLine = False
    for line in lines:
        if "//__BEGIN__CPP__IMPL__" in line:
            shouldAddLine = True
            continue
        if "//__END__CPP__IMPL__" in line:
            shouldAddLine = False
            break
        if "//__INCLUDE__INTERNALS__STATICALLY__" in line:
            cpp_exports_impl += f'\n//including internal classes\n'
            for klass in classes_to_initialize:
                cpp_exports_impl += f'#include "{klass[1]}"\n'
            continue
        if "//__INITIALIZE__INTERNALS__STATICALLY__" in line:
            cpp_exports_impl += f'\n    //initializing prefabs!\n'
            for klass in classes_to_initialize:
                cpp_exports_impl += f'    {klass[0]}();\n'

            continue
        
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

os.system(f'dart run ffigen --config ffigen_typhon.yaml')

os.system('echo "Done updating dart bindings file!"')

if not args.run_tests:
    quit()

os.chdir("cpp_library/build")
if platform.system() == "Darwin":
    os.system('echo "Building tests...')


    os.system(f'{"make typhon_tests"}')

    os.system('echo "Build finished!"')

os.system('echo "Running tests"')

if platform.system() == "Darwin":
    subprocess.call(["open","typhon_tests"])
else:
    subprocess.call(["typhon_tests.exe"])
    
