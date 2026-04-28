class Subject {
  final String id;
  final String name;
  final String code;

  Subject({required this.id, required this.name, required this.code});

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id'] as String,
        name: json['name'] as String,
        code: json['code'] as String,
      );
}
