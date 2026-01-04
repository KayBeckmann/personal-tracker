import 'package:flutter/material.dart';

/// Zeiterfassung
class TimeTrackingPage extends StatelessWidget {
  const TimeTrackingPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Zeiterfassung')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time, size: 64),
              SizedBox(height: 16),
              Text(
                'Zeiterfassung',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Wird in Meilenstein 5 implementiert'),
            ],
          ),
        ),
      );
}
