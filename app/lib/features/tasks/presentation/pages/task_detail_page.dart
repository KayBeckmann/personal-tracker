import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../data/database/tables/tasks_table.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/get_all_tasks.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/update_task_status.dart';

class TaskDetailPage extends StatefulWidget {
  const TaskDetailPage({required this.taskId, super.key});
  final int taskId;
  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final _getAllTasks = getIt<GetAllTasks>();
  final _updateTask = getIt<UpdateTask>();
  final _updateStatus = getIt<UpdateTaskStatus>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  Task? _task;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadTask() async {
    final tasks = await _getAllTasks();
    final task = tasks.firstWhere((t) => t.id == widget.taskId);
    if (mounted) {
      setState(() {
        _task = task;
        _titleController.text = task.title;
        _descController.text = task.description;
      });
    }
  }

  Future<void> _save() async {
    if (_task == null) return;
    final updated = _task!.copyWith(title: _titleController.text, description: _descController.text);
    await _updateTask(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gespeichert')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_task == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aufgabe bearbeiten'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _save),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Titel', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Beschreibung', border: OutlineInputBorder()), maxLines: 5),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Status'),
              trailing: DropdownButton<TaskStatus>(
                value: _task!.status,
                items: TaskStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                onChanged: (s) async {
                  if (s != null) {
                    await _updateStatus(_task!.id, s);
                    _loadTask();
                  }
                },
              ),
            ),
            if (_task!.dueDate != null)
              ListTile(
                title: const Text('Fällig am'),
                trailing: Text(DateFormat('dd.MM.yyyy').format(_task!.dueDate!)),
              ),
          ],
        ),
      ),
    );
  }
}
