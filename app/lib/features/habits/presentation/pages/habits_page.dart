import 'package:flutter/material.dart';

/// Gewohnheiten
class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Gewohnheiten')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.track_changes, size: 64),
              SizedBox(height: 16),
              Text(
                'Gewohnheiten',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Wird in Meilenstein 4 implementiert'),
            ],
          ),
        ),
      );
}
