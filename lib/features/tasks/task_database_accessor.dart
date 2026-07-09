import '../../core/database/models/task.dart';
import '../../core/database/repositories/task_repository.dart';

/// 課題テーブルに対するCRUD操作を担当する（M3-5 課題データベースアクセス処理）
class TaskDatabaseAccessor {
  TaskDatabaseAccessor({TaskRepository? taskRepository})
      : _taskRepository = taskRepository ?? TaskRepository();

  final TaskRepository _taskRepository;

  Future<List<Task>> getTasks() => _taskRepository.getTasks();

  Future<void> saveCompletionReport({
    required int taskId,
    required int feeling,
  }) {
    return _taskRepository.reportTaskCompletion(id: taskId, feeling: feeling);
  }

  Future<void> revertCompletion({required int taskId}) {
    return _taskRepository.revertTaskCompletion(id: taskId);
  }
}