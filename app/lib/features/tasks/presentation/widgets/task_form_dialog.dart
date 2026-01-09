import 'package:flutter/material.dart';
import '../../data/database/tables/tasks_table.dart';

class TaskFormDialog extends StatefulWidget {
  const TaskFormDialog({required this.onSave, this.initialTask, super.key});
  final Future<void> Function(String title, String description, TaskStatus status, TaskPriority priority, DateTime? dueDate, int? noteId) onSave;
  final dynamic initialTask;

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TaskStatus _status = TaskStatus.open;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      await widget.onSave(_titleController.text, _descController.text, _status, _priority, _dueDate, null);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Neue Aufgabe'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titel', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Bitte Titel eingeben' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Beschreibung', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priorität', border: OutlineInputBorder()),
                items: TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                onChanged: (v) => setState(() => _priority = v!),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_dueDate == null ? 'Kein Fälligkeitsdatum' : 'Fällig: ${_dueDate!.day}.${_dueDate!.month}.${_dueDate!.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => _dueDate = date);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
        ElevatedButton(onPressed: _save, child: const Text('Erstellen')),
      ],
    );
  }
}
