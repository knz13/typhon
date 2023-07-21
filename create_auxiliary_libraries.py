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

def compile_auxiliary_libraries(run_tests=False,release=False):

    if platform.system() != "Darwin":
        os.system('echo Installing Ninja build system!')
        os.system("pip install ninja")
  
    for directory in os.listdir("auxiliary_libraries"):
        if(not os.path.isdir("auxiliary_libraries/" + directory)):
            continue
        os.chdir("auxiliary_libraries/" + directory)

        exec(f"import auxiliary_libraries.{directory}.create_library as {directory}")
        exec(f"{directory}.create_library()")
        
        os.chdir("../../")
        

if __name__ == "__main__":


    compile(release=True)