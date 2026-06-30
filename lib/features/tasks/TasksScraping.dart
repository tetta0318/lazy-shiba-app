import 'package:html/parser.dart' as html_parser;
import 'package:dio/dio.dart' as dio;
import 'package:html/dom.dart' as html_dom;

import '../../core/database/models/subject.dart';
import '../../core/database/providers/subject_providers.dart';
import '../../core/database/models/task.dart';
import '../../core/database/providers/task_providers.dart';
import '../../core/database/repositories/task_repository.dart';
import '../../core/database/repositories/subject_repository.dart';

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
  final dio.Dio taskDio = dio.Dio();
  List<Assignment> assignmentList = [];

  // リポジトリを外部から注入、または初期化
  final TaskRepository _taskRepository = TaskRepository();
  final SubjectRepository _subjectRepository = SubjectRepository(); // 🏫 科目操作用

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

      // 🚀 【リポジトリ対応】解析したデータをリポジトリ経由で保存/同期する
      await _saveTasksToDatabase();

    } on dio.DioException catch (e) {
      print('❌ 課題一覧のHTTP通信に失敗しました: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ 課題一覧のパース処理中にエラーが発生しました: $e');
      rethrow;
    }
  }

  /// 🚀 課題リストをリポジトリを介して保存・同期する内部メソッド
  Future<void> _saveTasksToDatabase() async {
    print('💾 データベースへの同期を開始します...');

    // 既存のタスク一覧を一括取得して、存在チェックを効率化する（リポジトリに getTasks があるため可能）
    final List<Task> existingTasks = await _taskRepository.getTasks();

    for (final assignment in assignmentList) {
      // 1. 科目（subjects）のIDを特定、または新規登録
      int finalSubjectTableId = await _findOrCreateSubject(assignment.subjectName);

      // 2. すでに同じtaskIdの課題が登録されているか確認
      final bool isExisting = existingTasks.any((t) => t.id == assignment.taskId);

      // Taskオブジェクトの作成（プロパティ名は定義されているTaskモデルに合わせて調整してください）
      final taskData = Task(
        id: assignment.taskId,
        subjectId: finalSubjectTableId,
        taskName: assignment.taskName,
        deadline: assignment.deadline,
        url: assignment.submissionURL,
        feeling: assignment.taskresponse,
        status: assignment.taskstatus,
      );

      if (!isExisting) {
        // 未登録の場合は新規作成
        await _taskRepository.createTask(taskData);
        print(' ➕ 新規課題を登録しました: ${assignment.taskName}');
      } else {
        // 既に登録済みの場合は更新
        await _taskRepository.updateTask(taskData);
        print(' 🔄 既存の課題を更新しました: ${assignment.taskName}');
      }
    }
    print('✨ すべての課題データの同期が完了しました！');
  }

  /// 科目名から既存の科目IDを探し、なければ新規作成してそのIDを返すヘルパーメソッド
  Future<int> _findOrCreateSubject(String subjectName) async {
    // 全科目を取得して、名前が一致するものを探す
    // ※ 💡 SubjectRepository に getSubjects() や createSubject() がある前提の疑似コードです。
    // ※ 💡 もし未実装なら、必要に応じてリポジトリ側にメソッドを追加してください。
    final List<Subject> allSubjects = await _subjectRepository.getSubjects();
    
    for (final subject in allSubjects) {
      if (subject.subjectName == subjectName) {
        return subject.id; // 既存の科目IDを返す
      }
    }

    print(' 🏫 新しい科目を検出したため登録します: $subjectName');
    
    final newSubject = Subject(
      id: 0, // データベース側で自動採番される想定
      subjectName: subjectName,
      isOnline: 0,
      attendanceCount: 0,
      totalClassCount: 0,
    );

    // 新規登録して、生成されたIDをリポジトリから受け取る
    final int createdId = await _subjectRepository.createSubject(newSubject);
    return createdId;
  }
}
