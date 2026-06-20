import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/student_service.dart';

class StudentHistoryScreen extends StatelessWidget {
  const StudentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<StudentService>(context);
    final list = svc.entries;
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance History')),
      body: list.isEmpty
          ? const Center(child: Text('No attendance recorded yet'))
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (ctx, i) {
                final e = list[i];
                return ListTile(
                  title: Text('${e.moduleName} • ${e.studentName}'),
                  subtitle: Text('${e.admissionNumber} • ${e.timestamp}'),
                );
              },
            ),
    );
  }
}
