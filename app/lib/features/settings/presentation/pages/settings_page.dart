import 'package:flutter/material.dart';

/// Einstellungen
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Einstellungen')),
        body: ListView(
          children: const [
            ListTile(
              leading: Icon(Icons.palette),
              title: Text('Design'),
              subtitle: Text('Theme, Farben, Schriftarten'),
            ),
            ListTile(
              leading: Icon(Icons.language),
              title: Text('Sprache'),
              subtitle: Text('Deutsch'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.apps),
              title: Text('Module'),
              subtitle: Text('Features aktivieren/deaktivieren'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Über'),
              subtitle: Text('Version 1.0.0+1'),
            ),
          ],
        ),
      );
}
