import 'package:flutter/material.dart';

/// Aufgaben
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Aufgaben')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_box, size: 64),
              SizedBox(height: 16),
              Text(
                'Aufgaben',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Wird in Meilenstein 3 implementiert'),
            ],
          ),
        ),
      );
}
