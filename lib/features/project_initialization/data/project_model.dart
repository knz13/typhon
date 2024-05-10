


import 'package:typhon/features/project_initialization/data/project_type.dart';

class ProjectModel {
  final String name;
  final String location;
  final DateTime lastModified;
  final ProjectType type;
  final String version;
  final String executableName;

  ProjectModel({required this.name, required this.location,
    required this.version,
    required this.executableName,
    required this.type,
    required this.lastModified});

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      version: json['version'],
      executableName: json['executable_name'],
      type: ProjectType.fromJson(json['type']),
      lastModified: json["last_modified"] != null?  DateTime.parse(json['last_modified']).toLocal() : DateTime.now(),
      name: json['name'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'executable_name': executableName,
      'location': location,
      'version': version,
      'last_modified': lastModified.toUtc().toIso8601String(),
      'type': type.toJson(),
    };
  }

}