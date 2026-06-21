import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/session.dart';
import '../services/session_service.dart';
import 'session_qr_screen.dart';

class CreateSessionScreen extends StatefulWidget {
  final Session? editSession;
  const CreateSessionScreen({super.key, this.editSession});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    final s = widget.editSession;
    if (s != null) {
      _data['name'] = s.name;
      _data['numberOfStudents'] = s.numberOfStudents.toString();
      _data['date'] = s.date;
      _data['level'] = s.level;
      _data['moduleName'] = s.moduleName;
      _data['url'] = s.url;
      _data['timerMinutes'] = s.timerMinutes.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<SessionService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text(widget.editSession == null ? 'Create Session' : 'Edit Session')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _data['name'] as String?,
                decoration: const InputDecoration(labelText: 'Session name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                onSaved: (v) => _data['name'] = v ?? '',
              ),
              TextFormField(
                initialValue: _data['moduleName'] as String?,
                decoration: const InputDecoration(labelText: 'Module name'),
                onSaved: (v) => _data['moduleName'] = v ?? '',
              ),
              TextFormField(
                initialValue: _data['numberOfStudents'] as String?,
                decoration: const InputDecoration(labelText: 'Number of students'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _data['numberOfStudents'] = v ?? '0',
              ),
              TextFormField(
                initialValue: _data['date'] as String?,
                decoration: const InputDecoration(labelText: 'Date (e.g. 2026-06-20)'),
                onSaved: (v) => _data['date'] = v ?? '',
              ),
              TextFormField(
                initialValue: _data['level'] as String?,
                decoration: const InputDecoration(labelText: 'Level / Class'),
                onSaved: (v) => _data['level'] = v ?? '',
              ),
              TextFormField(
                initialValue: _data['url'] as String?,
                decoration: const InputDecoration(labelText: 'Connection URL (optional)'),
                onSaved: (v) => _data['url'] = v ?? '',
              ),
              TextFormField(
                initialValue: _data['timerMinutes'] as String?,
                decoration: const InputDecoration(labelText: 'Connection timer (minutes)'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _data['timerMinutes'] = v ?? '0',
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  _formKey.currentState?.save();
                  final s = widget.editSession;
                  if (s == null) {
                    final session = Session(
                      name: _data['name'] as String,
                      numberOfStudents: int.tryParse(_data['numberOfStudents'] as String) ?? 0,
                      date: _data['date'] as String,
                      level: _data['level'] as String,
                      moduleName: _data['moduleName'] as String,
                      url: _data['url'] as String,
                      timerMinutes: int.tryParse(_data['timerMinutes'] as String) ?? 0,
                    );
                    try {
                      await svc.add(session);
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => SessionQrScreen(session: session)),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error creating session: $e'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } else {
                    s.name = _data['name'] as String;
                    s.numberOfStudents = int.tryParse(_data['numberOfStudents'] as String) ?? 0;
                    s.date = _data['date'] as String;
                    s.level = _data['level'] as String;
                    s.moduleName = _data['moduleName'] as String;
                    s.url = _data['url'] as String;
                    s.timerMinutes = int.tryParse(_data['timerMinutes'] as String) ?? 0;
                    try {
                      await svc.update(s);
                      if (!mounted) return;
                      Navigator.pop(context);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating session: $e'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                child: Text(widget.editSession == null ? 'Create & Show QR' : 'Save changes'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
