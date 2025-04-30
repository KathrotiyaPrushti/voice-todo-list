import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:project_exam/models/task.dart';

class TaskProvider with ChangeNotifier {
  final Box<Map> _localBox = Hive.box('tasks');
  
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  TaskProvider() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final localTasks = _localBox.values.map((data) {
        final map = Map<String, dynamic>.from(data);
        return Task.fromMap(map);
      }).toList();
      _tasks = localTasks.where((task) => !task.isDeleted).toList();
    } catch (e) {
      print('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(String title) async {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    try {
      await _localBox.put(task.id, task.toMap());
      _tasks.add(task);
      notifyListeners();
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex == -1) return;

    final task = _tasks[taskIndex];
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
    );

    try {
      await _localBox.put(taskId, updatedTask.toMap());
      _tasks[taskIndex] = updatedTask;
      notifyListeners();
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      final task = _tasks.firstWhere((task) => task.id == taskId);
      final updatedTask = task.copyWith(isDeleted: true);
      await _localBox.put(taskId, updatedTask.toMap());
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      print('Error deleting task: $e');
    }
  }
} 