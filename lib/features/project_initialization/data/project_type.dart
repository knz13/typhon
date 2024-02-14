


class ProjectType {
  final String name;
  final String description;
  final String id;


  ProjectType({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ProjectType.fromJson(Map<String, dynamic> json) {
    return ProjectType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

}