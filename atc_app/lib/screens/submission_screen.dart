import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/student_service.dart';

class SubmissionScreen extends StatefulWidget {
  final Map<String, dynamic> payload;
  const SubmissionScreen({super.key, required this.payload});

  @override
  State<SubmissionScreen> createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends State<SubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _admission = '';
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final payload = widget.payload;
    final sessionName = payload['name'] as String? ?? payload['module'] as String? ?? 'Unknown session';
    final moduleName = payload['module'] as String? ?? '';
    final sessionId = payload['sessionId'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Submit Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Session: $sessionName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Module: $moduleName'),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter your name' : null,
                onSaved: (value) => _name = value?.trim() ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Admission number'),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter your admission number' : null,
                onSaved: (value) => _admission = value?.trim() ?? '',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                        if (!(_formKey.currentState?.validate() ?? false)) return;
                        _formKey.currentState?.save();
                        setState(() => _isSaving = true);
                        final studentService = Provider.of<StudentService>(context, listen: false);
                        await studentService.addAttendance(
                          sessionId: sessionId,
                          studentName: _name,
                          admissionNumber: _admission,
                          moduleName: moduleName,
                        );
                        if (!mounted) return;
                        setState(() => _isSaving = false);
                        showDialog<void>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Attendance Recorded'),
                            content: const Text('Your attendance has been recorded successfully.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                    ..pop()
                                    ..pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                child: _isSaving ? const CircularProgressIndicator() : const Text('Submit Attendance'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
