class StudentAttendance {
  final String id;
  final String sessionId;
  final String studentName;
  final String admissionNumber;
  final String timestamp; // ISO
  final String moduleName;

  StudentAttendance({
    required this.id,
    required this.sessionId,
    required this.studentName,
    required this.admissionNumber,
    required this.timestamp,
    required this.moduleName,
  });

  factory StudentAttendance.fromJson(Map<String, dynamic> j) {
    String readString(String camel, String snake) {
      final value = j[camel] ?? j[snake];
      if (value is String) return value;
      if (value != null) return value.toString();
      return '';
    }

    return StudentAttendance(
      id: readString('id', 'id'),
      sessionId: readString('sessionId', 'session_id'),
      studentName: readString('studentName', 'student_name'),
      admissionNumber: readString('admissionNumber', 'admission_number'),
      timestamp: readString('timestamp', 'timestamp'),
      moduleName: readString('moduleName', 'module_name'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'studentName': studentName,
        'admissionNumber': admissionNumber,
        'timestamp': timestamp,
        'moduleName': moduleName,
      };

  Map<String, dynamic> toSupabaseJson() => {
        'id': id,
        'session_id': sessionId,
        'student_name': studentName,
        'admission_number': admissionNumber,
        'module_name': moduleName,
        'timestamp': timestamp,
      };
}
