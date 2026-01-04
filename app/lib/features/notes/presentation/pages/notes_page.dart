import 'package:flutter/material.dart';

/// Notizen
class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Notizen')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.note, size: 64),
              SizedBox(height: 16),
              Text(
                'Notizen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Wird in Meilenstein 3 implementiert'),
            ],
          ),
        ),
      );
}
