import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_exam/providers/task_provider.dart';
import 'package:project_exam/models/task.dart';

class TaskList extends StatelessWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        if (taskProvider.tasks.isEmpty) {
          return const Center(
            child: Text(
              'No tasks yet. Use the mic button to add tasks!',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: taskProvider.tasks.length,
          itemBuilder: (context, index) {
            final task = taskProvider.tasks[index];
            return TaskItem(task: task);
          },
        );
      },
    );
  }
}

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => context.read<TaskProvider>().deleteTask(task.id),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => context.read<TaskProvider>().toggleTaskCompletion(task.id),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          'Created: ${task.createdAt.toString().split('.')[0]}',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
} 