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
from python_scripts.download_dependencies import download_dependencies

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
    save_location = os.path.abspath(save_location)
    print(f"Downloading {url}...")
    if url.endswith(".zip"):
        with urlopen(url) as zipresp:
            # save
            with open("temp.zip", "wb") as f:
                f.write(zipresp.read())
            

        with ZipFile("temp.zip","r") as zfile:
            zfile.extractall(save_location)
        


        return
    if url.endswith(".gz"):
        response = requests.get(url, stream=True)
        file = tarfile.open(fileobj=response.raw, mode="r|gz")
        print(f"Extracting {url} to {save_location}...")
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


import create_auxiliary_libraries as aux_libs

aux_libs.compile_auxiliary_libraries(run_tests=args.run_tests,release=False)



is_64bits = sys.maxsize > 2**32

current_dir = os.path.abspath(os.curdir)


os.chdir("cpp_library")
if not os.path.exists("src/vendor"):
    os.mkdir("src/vendor")



#downloading dependencies

#if get_first_available_cpp_compiler() == None:

download_dependencies()



if False:
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

# modify CMakeLists to remove everything between #__TESTING_TYPHON__ and #__END__TESTING_TYPHON__

with open("../assets/lib/CMakeLists.txt",'r') as f:
    lines = f.readlines()
    shouldAddLine = True
    new_lines = []
    for line in lines:
        if "#__TESTING_TYPHON__" in line:
            shouldAddLine = False
            continue
        if "#__END__TESTING_TYPHON__" in line:
            shouldAddLine = True
            continue
        if shouldAddLine:
            new_lines.append(line)
    
    with open("../assets/lib/CMakeLists.txt",'w') as f:
        f.write("".join(new_lines))

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


print(f"Writting to cpp_library/src/typhon_generated.cpp")
with open("cpp_library/src/typhon_generated.cpp","w") as f:
    f.write(cpp_exports_impl)



if False:
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
        

