import 'package:html/parser.dart' as html_parser;
import 'package:dio/dio.dart' as dio;
import 'package:html/dom.dart' as html_dom;

import '../../core/database/models/task.dart';
import '../../core/database/repositories/subject_repository.dart';
import '../../core/database/repositories/task_repository.dart';

class Assignment {
  final int taskId;
  final String subjectId;
  final String taskName;
  final String subjectName;
  final String deadline;
  final String submissionURL;
  final int taskresponse;
  final int taskstatus;

  Assignment({
    required this.taskId,
    this.subjectId = '',
    required this.taskName,
    required this.subjectName,
    required this.deadline,
    required this.submissionURL,
    this.taskresponse = 0,
    this.taskstatus = 0,
  });
}

class TasksScraping {
  TasksScraping({
    SubjectRepository? subjectRepository,
    TaskRepository? taskRepository,
  })  : _subjectRepository = subjectRepository ?? SubjectRepository(),
        _taskRepository = taskRepository ?? TaskRepository();

  final SubjectRepository _subjectRepository;
  final TaskRepository _taskRepository;
  final dio.Dio taskDio = dio.Dio();
  List<Assignment> assignmentList = [];

  Future<void> getTasks() async {
    assignmentList.clear();

    try {
      print('【通信開始】ScombZの課題一覧ページを取得しています...');
      final dio.Response response = await taskDio.get('https://scombz.shibaura-it.ac.jp/lms/task');
      final String htmlString = response.data.toString();

      html_dom.Document document = html_parser.parse(htmlString);

      List<html_dom.Element> taskElements = document.querySelectorAll('.result_list_line');
      int fallbackIdCounter = 1;

      for (final html_dom.Element row in taskElements) {
        // --- 科目名の取得 ---
        final html_dom.Element? courseElement = row.querySelector('.tasklist-course');
        final String subjectName = courseElement?.text.trim() ?? '科目不明';

        // --- 課題名と提出URLの取得 ---
        final html_dom.Element? anchor = row.querySelector('.tasklist-title a');
        final String taskName = anchor?.text.trim() ?? 'タイトルなし';
        final String submissionURL = anchor?.attributes['href'] ?? '';

        // --- URLから各IDの抽出ロジック ---
        int taskId = fallbackIdCounter++;
        String subjectId = '';

        if (submissionURL.isNotEmpty) {
          try {
            final Uri uri = Uri.parse('https://scombz.shibaura-it.ac.jp$submissionURL');
            final String? reportId = uri.queryParameters['reportId'];
            final String? idnumber = uri.queryParameters['idnumber'];

            if (reportId != null) {
              taskId = int.tryParse(reportId) ?? taskId;
            }
            if (idnumber != null) {
              subjectId = idnumber;
            }
          } catch (_) {
            // パース失敗時
          }
        }

        // --- 提出期限の取得 ---
        final html_dom.Element? deadlineElement = row.querySelector('.deadline');
        final String deadline = deadlineElement?.text.trim() ?? '';

        final assignment = Assignment(
          taskId: taskId,
          subjectId: subjectId,
          taskName: taskName,
          subjectName: subjectName,
          deadline: deadline,
          submissionURL: submissionURL,
        );

        assignmentList.add(assignment);
      }

      print('🎉 【解析成功】課題数: ${assignmentList.length} 件');

      // 🚀 【新規追加】解析したデータをSQLiteデータベースに登録/同期する
      await _saveTasksToDatabase();

    } on dio.DioException catch (e) {
      print('❌ 課題一覧のHTTP通信に失敗しました: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ 課題一覧のパース処理中にエラーが発生しました: $e');
      rethrow;
    }
  }

  /// 🚀 課題リストをSQLiteデータベースに保存・同期する内部メソッド
  Future<void> _saveTasksToDatabase() async {
    print('💾 データベースへの同期を開始します...');

    for (final assignment in assignmentList) {
      final subjectId = await _subjectRepository.findOrCreateSubject(
        subjectName: assignment.subjectName,
      );
      final existingTask = await _taskRepository.getTaskById(assignment.taskId);
      final now = DateTime.now();
      final task = Task(
        id: assignment.taskId,
        subjectId: subjectId,
        taskName: assignment.taskName,
        deadline: _parseDeadline(assignment.deadline),
        url: assignment.submissionURL.isEmpty ? null : assignment.submissionURL,
        feeling: assignment.taskresponse,
        status: assignment.taskstatus,
        createdAt: existingTask?.createdAt ?? now,
        updatedAt: now,
      );

      if (existingTask == null) {
        await _taskRepository.createTask(task);
        print(' ➕ 新規課題を登録しました: ${assignment.taskName}');
      } else {
        await _taskRepository.updateTask(task);
        print(' 🔄 既存の課題を更新しました: ${assignment.taskName}');
      }
    }
    print('✨ すべての課題データの同期が完了しました！');
  }

  DateTime _parseDeadline(String deadline) {
    final normalized = deadline
        .replaceAll('年', '-')
        .replaceAll('月', '-')
        .replaceAll('日', ' ')
        .replaceAll('/', '-')
        .trim();

    final parsed = DateTime.tryParse(normalized);
    if (parsed != null) {
      return parsed;
    }

    final match = RegExp(
      r'(\d{4})[-/年](\d{1,2})[-/月](\d{1,2})(?:[日\s]+(\d{1,2}):(\d{1,2}))?',
    ).firstMatch(deadline);

    if (match != null) {
      final year = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      final day = int.parse(match.group(3)!);
      final hour = int.tryParse(match.group(4) ?? '') ?? 23;
      final minute = int.tryParse(match.group(5) ?? '') ?? 59;
      return DateTime(year, month, day, hour, minute);
    }

    return DateTime.now();
  }
}
