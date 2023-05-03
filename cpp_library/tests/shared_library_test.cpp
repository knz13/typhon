#include <iostream>
#include <algorithm>
#include <filesystem>
#include <unistd.h>
#include <dlfcn.h>


int main() {


    std::cout << "initializing and opening library" << std::endl;

    char currentDir[PATH_MAX];

    if (getcwd(currentDir, sizeof(currentDir)) != nullptr) {
        std::cout << "Current directory is: " << currentDir << std::endl;
    }

    #ifdef __APPLE__
    void* handle = dlopen("libtyphon_shared_tests_lib.dylib", RTLD_LAZY);

    

    dlclose(handle);
    #endif

    return 0;
}
