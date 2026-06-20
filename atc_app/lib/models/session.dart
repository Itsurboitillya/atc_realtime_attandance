import 'package:uuid/uuid.dart';

class Session {
  final String id;
  String name;
  int numberOfStudents;
  String date; // ISO or user string
  String level;
  String moduleName;
  String url;
  int timerMinutes;
  String createdAt;

  Session({
    String? id,
    required this.name,
    required this.numberOfStudents,
    required this.date,
    required this.level,
    required this.moduleName,
    required this.url,
    required this.timerMinutes,
    String? createdAt,
  })  : id = id ?? Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().toIso8601String();

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json['id'] as String?,
        name: json['name'] as String? ?? '',
        numberOfStudents: (json['numberOfStudents'] ?? 0) as int,
        date: json['date'] as String? ?? '',
        level: json['level'] as String? ?? '',
        moduleName: json['moduleName'] as String? ?? '',
        url: json['url'] as String? ?? '',
        timerMinutes: (json['timerMinutes'] ?? 0) as int,
        createdAt: json['createdAt'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'numberOfStudents': numberOfStudents,
        'date': date,
        'level': level,
        'moduleName': moduleName,
        'url': url,
        'timerMinutes': timerMinutes,
        'createdAt': createdAt,
      };
}
