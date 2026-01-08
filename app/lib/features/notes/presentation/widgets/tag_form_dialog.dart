import 'package:flutter/material.dart';

/// Dialog zum Erstellen eines neuen Tags
class TagFormDialog extends StatefulWidget {
  const TagFormDialog({
    required this.onSave,
    super.key,
  });

  final Future<void> Function(String name, String? color) onSave;

  @override
  State<TagFormDialog> createState() => _TagFormDialogState();
}

class _TagFormDialogState extends State<TagFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedColor;

  final List<String> _colors = [
    'EF5350', // Red
    'EC407A', // Pink
    'AB47BC', // Purple
    '5C6BC0', // Indigo
    '42A5F5', // Blue
    '26A69A', // Teal
    '66BB6A', // Green
    '9CCC65', // Light Green
    'FFEE58', // Yellow
    'FFA726', // Orange
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      await widget.onSave(
        _nameController.text,
        _selectedColor,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Neuer Tag'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte Namen eingeben';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Farbe (optional):'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colors.map((color) {
                final isSelected = _selectedColor == color;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedColor = isSelected ? null : color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse('0xFF$color')),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3,
                            )
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Erstellen'),
        ),
      ],
    );
  }
}
