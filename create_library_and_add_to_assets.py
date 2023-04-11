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
if not os.path.exists("src/vendor"):
    os.mkdir("src/vendor")





if not os.path.exists("src/vendor/shaderc"):
    os.system('echo downloading shaderc library...')
    os.system("git clone https://github.com/google/shaderc src/vendor/shaderc")
    os.system(("python " if platform.system() != "Darwin" else "") + "src/vendor/shaderc/utils/git-sync-deps")

os.system('echo "Creating c++ library..."')
#os.system(f'cmake {("-DCMAKE_BUILD_TYPE=" + ("Release" if args.Release else "Debug")) if platform.system() == "Darwin" else ("-DCMAKE_GENERATOR_PLATFORM=" + ("x64" if is_64bits else "x86"))} -B build ./ ')
proc = subprocess.Popen([f'cmake {("-DCMAKE_BUILD_TYPE=" + ("Release" if args.Release else "Debug")) if platform.system() == "Darwin" else ("-DCMAKE_GENERATOR_PLATFORM=" + ("x64" if is_64bits else "x86"))} -B build ./ '], stdout=subprocess.PIPE, shell=True)
(out,err) = proc.communicate()
out = str(out)
""" subst_begin = out.find("BEGIN__INCLUDE__DIRS")
subst_end = out.find("END__INCLUDE__DIRS")
dirs_to_include = out[subst_begin+len("BEGIN__INCLUDE__DIRS "):subst_end].split(";")
for i in dirs_to_include:
    print(r"target_include_directories(${PROJECT_NAME} PUBLIC " + os.path.relpath(i,os.path.join(current_dir,"c_sharp_interface","src")) + ")")
 """
os.system('echo "CMake run finished!')
os.system('echo "Compiling..."')
os.chdir("build")
os.system(f'{"make typhon" if platform.system() == "Darwin" else "msbuild project_typhon.sln /target:typhon /p:Configuration=" + ("Release" if args.Release else "Debug")}')
os.system('echo "Moving library to assets..."')

if platform.system() == "Darwin":
    if os.path.exists(os.path.abspath("../../assets/lib/libtyphon.a")):
        os.remove(os.path.abspath("../../assets/lib/libtyphon.a"))
    os.rename(os.path.abspath("libtyphon.a"),os.path.abspath("../../assets/lib/libtyphon.a"))
else:
    if os.path.exists(os.path.abspath("../../assets/lib/typhon.lib")):
        os.remove(os.path.abspath("../../assets/lib/typhon.lib"))
    os.rename(os.path.abspath("Debug/typhon.lib" if not args.Release else "Release/typhon.lib"),os.path.abspath("../../assets/lib/typhon.lib"))
    
os.chdir(os.path.join(current_dir,"c_sharp_interface"))

if(os.path.exists(os.path.join(current_dir,"assets/lib/include"))):
    for root, dirs, files in os.walk(os.path.join(current_dir,"assets/lib/include")):
        for file in files:
            os.remove(os.path.join(root,file))



for root, dirs, files in os.walk('src'):
    root = os.path.abspath(root)
    for file in files:
        if not os.path.exists(os.path.join("../assets/lib/includes",os.path.relpath(root,os.path.join(current_dir,"c_sharp_interface","src")))):
            os.makedirs(os.path.join("../assets/lib/includes",os.path.relpath(root,os.path.join(current_dir,"c_sharp_interface","src"))),exist_ok=True)
        if file.endswith(".h") or file.endswith(".hpp") or file.endswith(".inl"):
            #print(f"doing {os.path.join(root,file)}")
            shutil.copyfile(os.path.join(root,file),os.path.join("../assets/lib/includes",os.path.relpath(root,os.path.join(current_dir,"c_sharp_interface","src")),file))



os.system('echo "Build finished!"')

os.system('echo "Updating dart bindings file..."')

os.system(f'cd {current_dir} && dart run ffigen --config ffigen.yaml')

os.system('echo "Done updating dart bindings file!"')