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

  factory StudentAttendance.fromJson(Map<String, dynamic> j) =>
      StudentAttendance(
        id: j['id'] as String,
        sessionId: j['sessionId'] as String,
        studentName: j['studentName'] as String,
        admissionNumber: j['admissionNumber'] as String,
        timestamp: j['timestamp'] as String,
        moduleName: j['moduleName'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'studentName': studentName,
        'admissionNumber': admissionNumber,
        'timestamp': timestamp,
        'moduleName': moduleName,
      };
}
