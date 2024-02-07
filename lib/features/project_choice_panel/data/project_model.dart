


class ProjectModel {
  final String name;
  final String location;
  final DateTime lastModified;

  ProjectModel({required this.name, required this.location,
    required this.lastModified});

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      lastModified: json["lastModified"] != null?  DateTime.parse(json['lastModified']).toLocal() : DateTime.now(),
      name: json['name'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'lastModified': lastModified.toUtc().toIso8601String(),
    };
  }

}