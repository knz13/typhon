import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';
import 'package:typhon/features/project_initialization/data/project_type.dart';

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

        projects = map.entries
            .map((e) => ProjectModel.fromJson({
                  "name": e.value["name"],
                  "location": e.key,
                }))
            .toList();

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

  static Future<Either<String, bool>> createProject({required ProjectType type,required String name,required String location}) async {
    try {
      Directory privateDir = await getApplicationSupportDirectory();
      File projectsFile = File(path.join(privateDir.path, "projects.json"));
      if (projectsFile.existsSync()) {
        String fileData = projectsFile.readAsStringSync();
        var map = (jsonDecode(fileData)) as Map<String, dynamic>;

        if (map.containsKey(location)) {
          return const Left("Project already exists");
        }

        map[location] = {
          "name": name,
          "type": type,
        };

        projectsFile.writeAsStringSync(jsonEncode(map));

        return const Right(true);
      } else {
        projectsFile.writeAsStringSync("{}");

        return const Left("Projects file not found");
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}
