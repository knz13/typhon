import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';
import 'package:typhon/features/project_initialization/data/project_model.dart';
import 'package:path/path.dart' as path;

class EngineFrontendService {
  static Future<Either<String, String>> loadProject(
      ProjectModel project) async {
    String applicationDir = path.dirname(Platform.resolvedExecutable);

    try {
      if (!Directory(project.location).existsSync()) {
        return const Left("Project location does not exist");
      }

      if (!File(path.join(project.location, "typhon_project.json"))
          .existsSync()) {
        return const Left("Project file does not exist");
      }

      // reload typhon.h

      File typhonH = File(path.join(project.location, "typhon.h"));

      typhonH.writeAsString(createTyphonH());

      // reload variables in CMakeLists.txt

      File cmakeLists = File(path.join(project.location, "CMakeLists.txt"));

      List<String> lines = cmakeLists.readAsLinesSync();

      var strToWrite = "";

      for (var line in lines) {
        if (line.contains("# ADD_TYPHON_SUBDIR")) {
          strToWrite +=
              "add_subdirectory(${path.join(applicationDir, "lib/cpp_library")}) # ADD_TYPHON_SUBDIR\n";
          break;
        } else {
          strToWrite += "$line\n";
        }
      }

      cmakeLists.writeAsStringSync(strToWrite);

      return const Right("Project loaded successfully");
    } catch (e) {
      return Left(e.toString());
    }
  }

  static String createTyphonH() {
    String applicationDir = path.dirname(Platform.resolvedExecutable);

    return """
// Generated file, do not modify

#pragma once

// INIT_TYPHON_H
#include "${path.join(applicationDir,"lib/cpp_library/src/ui/ui_builder.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/ui/ui_element.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/auxiliary_libraries_helpers/auxiliary_library.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/auxiliary_libraries_helpers/auxiliary_libraries_interface.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/features/project_selection/project_selection_canvas.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/component/component.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/component/make_component.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/component/default_components/transform.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/utils/utils.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/utils/generic_reflection.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/utils/general.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/utils/color.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/utils/reflection_checks.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/utils/keyboard_adaptations.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/object/object_handle.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/object/object.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/object/object_storage.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/auxiliary_libraries/model_loader.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/auxiliary_libraries/shader_compiler.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/prefab/prefab.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/prefab/defaults/cube.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/prefab/defaults/empty_object.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/texture_packer/crunch_texture_packer.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/engine/rendering_canvas.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/engine/engine.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/engine/rendering_engine.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/engine/platform_specific/MacOS/metal_rendering_engine.h")}";
#include "${path.join(applicationDir,"lib/cpp_library/src/engine/entity_component_system/ecs_registry.h")}";
// END_TYPHON_H
""";
  }

  static String createCMakeLists(ProjectModel project) {
    String applicationDir = path.dirname(Platform.resolvedExecutable);

    return """
cmake_minimum_required(VERSION 3.16)

# project name
project(project_${project.name.toLowerCase().replaceAll(" ", "_").replaceAll("-", "_")})

# set c++ standard

set(CMAKE_CXX_STANDARD 20)

# create the executable

add_executable(${project.executableName} main.cpp
# INIT_PROJECT_CPP_FILES
# END_PROJECT_CPP_FILES
)

# include the typhon library subdirectory

add_subdirectory(${path.join(applicationDir, "lib/cpp_library")} build/typhon) # ADD_TYPHON_SUBDIR

# link the typhon library

target_link_libraries(${project.executableName} typhon)
""";
  }

  static String createMainCpp(ProjectModel project) {
    var val = """
#include "typhon.h"
// Do not remove the line below
// INIT_MAIN_CPP
using namespace Typhon;
int main()
{


    //Initializing internal classes, do not remove
    Transform();
    ModelLoader();
    ShaderCompiler();
    Cube();
    EmptyObject();

    Engine::Initialize();

    RenderingEngine::SetCurrentCanvas(std::make_shared<ProjectSelectionCanvas>());

    while (RenderingEngine::isRunning())
    {
        RenderingEngine::HandleEvents();

        RenderingEngine::Render();
    }

    Engine::Unload();

    return 0;
}
// END_MAIN_CPP
// Do not remove the line above
""";

    // remove all comments

    val = val.replaceAll(RegExp(r"// .*"), "");

    return val;
  }
}
