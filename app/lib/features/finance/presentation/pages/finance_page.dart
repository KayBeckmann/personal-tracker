import 'package:flutter/material.dart';

/// Haushaltsbuch / Finanzen
class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Finanzen')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance_wallet, size: 64),
              SizedBox(height: 16),
              Text(
                'Haushaltsbuch',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Wird in Meilenstein 2 implementiert'),
            ],
          ),
        ),
      );
}
