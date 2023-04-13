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

proc = subprocess.Popen(f'cmake -B build ./  {("-DCMAKE_BUILD_TYPE=" + ("Release" if args.Release else "Debug")) if platform.system() == "Darwin" else ("-DCMAKE_GENERATOR_PLATFORM=" + ("x64" if is_64bits else "x86"))}'.split(), stdout=subprocess.PIPE, shell=True)
(out,err) = proc.communicate()
out = str(out)

roots = []
shutil.copyfile("CMakeLists.txt","../assets/lib/CMakeLists.txt")
dir = os.listdir("src")
for root, dirs, files in os.walk('src'):
    root = os.path.abspath(root)
    for file in files:
        if file in dir or os.path.relpath(os.path.abspath(os.path.join(root,file)),os.path.abspath("src/vendor/")).count("..") == 0 and os.path.relpath(os.path.abspath(os.path.join(root,file)),os.path.abspath("src/vendor/shaderc")).count("..") == 0:
            if not os.path.exists(os.path.join("../assets/lib/src",os.path.relpath(root,os.path.join(current_dir,"c_sharp_interface","src")))):
                os.makedirs(os.path.join("../assets/lib/src/",os.path.relpath(root,os.path.join(current_dir,"c_sharp_interface","src"))),exist_ok=True)
            if root not in roots:
                roots.append(root)
            shutil.copyfile(os.path.join(root,file),os.path.join("../assets/lib/src",os.path.relpath(root,os.path.join(current_dir,"c_sharp_interface","src")),file))
    print(f"Done dir {root}")
for root in roots:
    path = os.path.relpath(root,os.path.join(current_dir,"c_sharp_interface","src")).replace("\\","/")
    print(f'    - assets/lib/src/{path}/')


os.system('echo "Build finished!"')

os.system('echo "Updating dart bindings file..."')

os.system(f'cd {current_dir} && dart run ffigen --config ffigen.yaml')

os.system('echo "Done updating dart bindings file!"')