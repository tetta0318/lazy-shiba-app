import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider({
    TaskRepository? repository,
  }) : _repository = repository ?? TaskRepository();

  final TaskRepository _repository;

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    _tasks = await _repository.getTasks();
    notifyListeners();
  }

  Future<void> loadTasksBySubjectId(int subjectId) async {
    _tasks = await _repository.getTasksBySubjectId(subjectId);
    notifyListeners();
  }

  Future<void> createTask(Task task) async {
    await _repository.createTask(task);
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await _repository.updateTask(task);
    await loadTasks();
  }

  Future<void> updateTaskStatus({
    required int id,
    required int status,
  }) async {
    await _repository.updateTaskStatus(
      id: id,
      status: status,
    );
    await loadTasks();
  }

  Future<void> updateTaskFeeling({
    required int id,
    required int feeling,
  }) async {
    await _repository.updateTaskFeeling(
      id: id,
      feeling: feeling,
    );
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await _repository.deleteTask(id);
    await loadTasks();
  }
}