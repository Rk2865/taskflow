import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class ApiService {
  // TODO: Replace with your actual Firebase Realtime Database URL
  // e.g., 'https://your-project-id-default-rtdb.firebaseio.com'
  static const String _baseUrl =
      'https://taskflow-955df-default-rtdb.firebaseio.com';

  // Helper method to get the URL for tasks of a specific user
  String _getTasksUrl(String userId) {
    return '$_baseUrl/users/$userId/tasks.json';
  }

  String _getTaskUrl(String userId, String taskId) {
    return '$_baseUrl/users/$userId/tasks/$taskId.json';
  }

  Future<Map<String, TaskModel>> fetchTasks(String userId) async {
    try {
      final response = await http.get(Uri.parse(_getTasksUrl(userId)));

      if (response.statusCode == 200) {
        if (response.body == 'null') return {};

        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, TaskModel> fetchedTasks = {};

        data.forEach((key, value) {
          fetchedTasks[key] = TaskModel.fromJson(value, key);
        });

        return fetchedTasks;
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tasks: $e');
    }
  }

  Future<String> addTask(String userId, TaskModel task) async {
    try {
      final response = await http.post(
        Uri.parse(_getTasksUrl(userId)),
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['name']; // This is the generated ID from Firebase
      } else {
        throw Exception('Failed to add task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding task: $e');
    }
  }

  Future<void> updateTask(String userId, TaskModel task) async {
    try {
      final response = await http.patch(
        Uri.parse(_getTaskUrl(userId, task.id)),
        body: json.encode(task.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating task: $e');
    }
  }

  Future<void> deleteTask(String userId, String taskId) async {
    try {
      final response = await http.delete(
        Uri.parse(_getTaskUrl(userId, taskId)),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting task: $e');
    }
  }
}
