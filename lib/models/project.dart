class Project {
  String id;
  String title;
  String description;
  DateTime startDate;
  DateTime endDate;
  String priority;
  String status;
  Map<String, String> members;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.priority,
    required this.status,
    required this.members,
  });

  factory Project.fromMap(String id, Map<String, dynamic> data) {
    return Project(
      id: id,
      title: data['title'],
      description: data['description'],
      startDate: DateTime.parse(data['startDate']),
      endDate: DateTime.parse(data['endDate']),
      priority: data['priority'],
      status: data['status'],
      members: Map<String, String>.from(data['members']),
    );
  }

}
