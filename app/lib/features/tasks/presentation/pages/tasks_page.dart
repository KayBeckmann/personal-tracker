import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../data/database/tables/tasks_table.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_all_tasks.dart';
import '../../domain/usecases/update_task_status.dart';
import '../widgets/task_form_dialog.dart';
import 'task_detail_page.dart';

/// Aufgaben-Übersicht mit Filter und Sortierung
class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _getAllTasks = getIt<GetAllTasks>();
  final _createTask = getIt<CreateTask>();
  final _deleteTask = getIt<DeleteTask>();
  final _updateStatus = getIt<UpdateTaskStatus>();

  final _searchController = TextEditingController();
  TaskStatus? _filterStatus;
  TaskPriority? _filterPriority;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showCreateDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => TaskFormDialog(
        onSave: (title, description, status, priority, dueDate, noteId) async {
          await _createTask(
            title: title,
            description: description,
            status: status,
            priority: priority,
            dueDate: dueDate,
            noteId: noteId,
          );
        },
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.blue;
    }
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'Hoch';
      case TaskPriority.medium:
        return 'Mittel';
      case TaskPriority.low:
        return 'Niedrig';
    }
  }

  String _getStatusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.open:
        return 'Offen';
      case TaskStatus.inProgress:
        return 'In Bearbeitung';
      case TaskStatus.completed:
        return 'Erledigt';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tasks),
        actions: [
          PopupMenuButton<TaskStatus?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (status) {
              setState(() => _filterStatus = status);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Alle Status'),
              ),
              ...TaskStatus.values.map((status) => PopupMenuItem(
                    value: status,
                    child: Text(_getStatusLabel(status)),
                  )),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Aufgaben durchsuchen...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _getAllTasks.watch(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_box, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text('Keine Aufgaben vorhanden', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  );
                }

                var tasks = snapshot.data!;

                // Filter
                if (_filterStatus != null) {
                  tasks = tasks.where((t) => t.status == _filterStatus).toList();
                }
                if (_searchController.text.isNotEmpty) {
                  final query = _searchController.text.toLowerCase();
                  tasks = tasks.where((t) =>
                      t.title.toLowerCase().contains(query) ||
                      t.description.toLowerCase().contains(query)).toList();
                }

                if (tasks.isEmpty) {
                  return const Center(child: Text('Keine passenden Aufgaben gefunden'));
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final dateFormat = DateFormat('dd.MM.yyyy');

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.status == TaskStatus.completed,
                          onChanged: (checked) async {
                            final newStatus = checked == true
                                ? TaskStatus.completed
                                : TaskStatus.open;
                            await _updateStatus(task.id, newStatus);
                          },
                        ),
                        title: Text(
                          task.title,
                          style: task.status == TaskStatus.completed
                              ? const TextStyle(decoration: TextDecoration.lineThrough)
                              : null,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (task.description.isNotEmpty)
                              Text(task.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor(task.priority).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _getPriorityLabel(task.priority),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _getPriorityColor(task.priority),
                                    ),
                                  ),
                                ),
                                if (task.dueDate != null) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.calendar_today,
                                    size: 12,
                                    color: task.isOverdue ? Colors.red : null,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    dateFormat.format(task.dueDate!),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: task.isOverdue ? Colors.red : null,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) => TaskDetailPage(taskId: task.id),
                                ),
                              );
                            } else if (value == 'delete') {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Aufgabe löschen?'),
                                  content: const Text('Möchten Sie diese Aufgabe wirklich löschen?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Abbrechen'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Löschen'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                await _deleteTask(task.id);
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
                            const PopupMenuItem(value: 'delete', child: Text('Löschen')),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => TaskDetailPage(taskId: task.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
