import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/session_service.dart';
import 'create_session_screen.dart';
import 'session_qr_screen.dart';

class SessionListScreen extends StatelessWidget {
  const SessionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<SessionService>(context);
    final sessions = svc.sessions;
    return Scaffold(
      body: sessions.isEmpty
          ? const Center(child: Text('No sessions yet. Tap + to create.'))
          : ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (ctx, i) {
                final s = sessions[i];
                return ListTile(
                  title: Text(s.name),
                  subtitle: Text('${s.moduleName} • ${s.date}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateSessionScreen(editSession: s),
                          ),
                        );
                      } else if (v == 'qr') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => SessionQrScreen(session: s)));
                      } else if (v == 'delete') {
                        await svc.remove(s.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'qr', child: Text('Show QR')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateSessionScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
