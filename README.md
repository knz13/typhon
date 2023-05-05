# Typhon Engine

A Game Engine written in Flutter/C++ to ease the entry barrier for C++ learners with an interactive UI made with flutter and make it easier to integrate existing C++ libraries in any game

## Building

In order to build the project you're gonna need to setup a few things:

* [Flutter SDK](https://docs.flutter.dev/get-started/install)

* [Python](https://www.python.org/downloads/)

* [CMake](https://cmake.org)

* [Visual Studio (If using windows)](https://visualstudio.microsoft.com/pt-br/)

__*CMake is only optional, we can download it for you as a dependency of the program when you run the python code but it might increase the time for building the c++ library at the first time__

After downloading and installing the dependencies, download the repository and run the script create_library_and_add_to_assets.py with the command below to generate the libraries that are bigger than what Github allows in their website

```
python setup_cpp_library.py
```

Then just run 
```
flutter run
```
Select a device to run and you're all set!


## Roadmap

- &check; Basic Engine UI
- &check; Basic Project Creation UI
- &check; Project Creation And Removal
- &check; Basic Engine in C++
- &check; Basic C++ Testing
- &check; Adding on-the-fly C++ Compilation
- &check; Dynamic Loading|Unloading of the C++ Library
- &check; Integration of the Shader Compiler to SPIRV ([shaderc](https://github.com/google/shaderc)) and the SPIRV to Shader Code Compiler ([spirv-cross](https://github.com/KhronosGroup/SPIRV-Cross))
- &check; Separating the Shader Compilers into another library
- &check; Dynamic Loading|Unloading of the C++ Library
- &check; Basic C++ User Script Creation and Hot Reload
- &check; Add Initial MacOS Rendering Engine Base
- &cross; Basic Rendering Engine Outline
- &cross; Add MacOS Support for Rendering Engine (Metal Backend)
- &cross; Add Windows Support for Rendering Engine (OpenGL Backend)







