class Topic {
  final String id;
  final String subjectId;
  final String name;
  final String summary;

  Topic({required this.id, required this.subjectId, required this.name, required this.summary});

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        id: json['id'] as String,
        subjectId: json['subject_id'] as String,
        name: json['name'] as String,
        summary: json['summary'] as String,
      );
}
