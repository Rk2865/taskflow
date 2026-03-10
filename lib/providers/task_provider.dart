import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';

class TaskProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> loadTasks(String userId) async {
    _setLoading(true);
    _setError(null);
    try {
      final fetchedTasksMap = await _apiService.fetchTasks(userId);
      _tasks = fetchedTasksMap.values.toList();
      _tasks.sort((a, b) => a.isCompleted ? 1 : -1);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addTask(String userId, String title, String description) async {
    _setLoading(true);
    _setError(null);
    try {
      // Create a temporary task without DB ID
      final newTask = TaskModel(
        id: '', // Will be updated
        title: title,
        description: description,
      );

      final dbId = await _apiService.addTask(userId, newTask);

      // Update local storage with the generated DB ID
      final taskWithId = newTask.copyWith(id: dbId);
      _tasks.add(taskWithId);

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTask(String userId, TaskModel task) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiService.updateTask(userId, task);

      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        _tasks.sort((a, b) => a.isCompleted ? 1 : -1);
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleTaskCompletion(String userId, TaskModel task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(userId, updatedTask);
  }

  Future<void> deleteTask(String userId, String taskId) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiService.deleteTask(userId, taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
