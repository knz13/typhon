import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:typhon/environment.dart';
import 'package:typhon/features/engine_frontend/domain/engine_frontend_service.dart';
import 'package:typhon/features/project_initialization/data/project_type.dart';
import 'package:typhon/utils/utils.dart';

import '../../../engine.dart';
import '../data/project_model.dart';
import 'package:path/path.dart' as path;

class ProjectInitializationService {
  static Future<Either<String, List<ProjectModel>>> getProjects() async {
    try {
      Directory privateDir = await getApplicationSupportDirectory();
      File projectsFile = File(path.join(privateDir.path, "projects.json"));
      if (projectsFile.existsSync()) {
        String fileData = projectsFile.readAsStringSync();
        var map = (jsonDecode(fileData)) as Map<String, dynamic>;

        List<ProjectModel> projects = [];

        projects =
            map.entries.map((e) => ProjectModel.fromJson(e.value)).toList();

        // check if directories exist
        var projectsToRemove = [];
        for (var project in projects) {
          if (!Directory(project.location).existsSync() ||
              !File(path.join(project.location, "typhon_project.json"))
                  .existsSync()) {
            projectsToRemove.add(project);
          }
        }

        projects.removeWhere((element) => projectsToRemove.contains(element));

        return Right(projects);
      } else {
        projectsFile.writeAsStringSync("{}");

        return const Right([]);
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  static Future<Either<String, List<ProjectType>>> getProjectTypes() async {
    try {
      var tempJSON = [
        ProjectType(
                id: "project_2d",
                name: "2D Project",
                description: "A 2D project for creating 2D games.")
            .toJson(),
        ProjectType(
                id: "project_3d",
                name: "3D Project",
                description: "A 3D project for creating 3D games.")
            .toJson(),
      ].map((e) => MapEntry<String, dynamic>(e["id"], e)).toList();

      List<ProjectType> projectTypes = [];

      projectTypes = Map.fromEntries(tempJSON)
          .entries
          .map((e) => ProjectType.fromJson(e.value))
          .toList();

      return Right(projectTypes);
    } catch (e) {
      return Left(e.toString());
    }
  }

  static Future<Either<String, bool>> createProject(
      {required ProjectType type,
      required String name,
      required String location}) async {
    try {
      location = path.join(location, Utils.normalizePathString(name));

      if (!Directory(location).existsSync()) {
        Directory(location).createSync();
      }

      Directory privateDir = await getApplicationSupportDirectory();
      File projectsFile = File(path.join(privateDir.path, "projects.json"));

      if (!projectsFile.existsSync()) {
        projectsFile.writeAsStringSync("{}");
      }

      String fileData = projectsFile.readAsStringSync();
      var map = (jsonDecode(fileData)) as Map<String, dynamic>;

      if (map.containsKey(location) &&
          File(path.join(location, "typhon_project.json")).existsSync()) {
        return const Right(true);
      }

      map[location] = ProjectModel(
              executableName:
                  name.toLowerCase().replaceAll(" ", "_").replaceAll("-", "_"),
              version: Environment.typhonVersion,
              name: name,
              location: location,
              lastModified: DateTime.now().toUtc(),
              type: type)
          .toJson();

      projectsFile.writeAsStringSync(jsonEncode(map));

      // create the typhon_project.json file in the project directory

      File projectFile = File(path.join(location, "typhon_project.json"));

      if (!projectFile.existsSync()) {
        projectFile.writeAsStringSync(jsonEncode(map[location]));
      }

      // create CMakeLists.txt

      File cmakeLists = File(path.join(location, "CMakeLists.txt"));

      if (!cmakeLists.existsSync()) {
        cmakeLists.writeAsStringSync(EngineFrontendService.createCMakeLists(
            ProjectModel.fromJson(map[location])));
      }

      // create the main.cpp file

      File mainCpp = File(path.join(location, "main.cpp"));

      if (!mainCpp.existsSync()) {
        mainCpp.writeAsStringSync(EngineFrontendService.createMainCpp(
            ProjectModel.fromJson(map[location])));
      }

      // create the typhon.h file

      File typhonH = File(path.join(location, "typhon.h"));

      if (!typhonH.existsSync()) {
        typhonH.writeAsStringSync(EngineFrontendService.createTyphonH());
      }

      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }

  static Future<Either<String, String>> unpackLibAssets(
      {required Function(int, int) onProgress}) async {
    String destination = path.join(
        path.dirname(Platform.resolvedExecutable), "lib", "cpp_library");
    if (!Directory(destination).existsSync()) {
      Directory(destination).createSync(recursive: true);
    }

    String assetManifestJson =
        await rootBundle.loadString('AssetManifest.json');
    Map<String, dynamic> assetManifestMap = json.decode(assetManifestJson);
    List<String> assetManifest = assetManifestMap.keys.toList();

    // get all that are under lib/src and move to lib/cpp_library

    List<String> assetFiles = assetManifest
        .where((p) =>
            path.isWithin("assets/lib", p) &&
            !p.contains("docs") &&
            !p.contains(".git"))
        .toList();

    int progress = 0;
    int total = assetFiles.length;
    for (String assetPath in assetFiles) {
      try {
        String imageName = path.relative(assetPath, from: "assets/lib");
        File includeFile = File(path.join(destination, imageName));

        // since the asset path can be under a subdirectory, we need to create the subdirectory

        if (!Directory(path.dirname(includeFile.path)).existsSync()) {
          Directory(path.dirname(includeFile.path)).createSync(recursive: true);
        }

        if (includeFile.existsSync()) {
          //print("Skipping ${includeFile.path}, already copied!");
          continue;
        }

        ByteData data = await rootBundle.load(assetPath);
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

        await includeFile.writeAsBytes(bytes, flush: true);
        //print("Created ${includeFile.path}!");
      } catch (e) {
        //print("Error extracting files from assets: $e");
      }

      onProgress(progress++, total);
    }
    return const Right("Unpacked assets");
  }
}
