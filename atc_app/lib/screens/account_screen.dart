import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 36)),
            const SizedBox(height: 12),
            const Text('Teacher', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.settings), label: const Text('Settings')),
            const SizedBox(height: 8),
            ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.logout), label: const Text('Logout')),
          ],
        ),
      ),
    );
  }
}
