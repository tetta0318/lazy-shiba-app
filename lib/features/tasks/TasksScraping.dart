import 'package:html/parser.dart' as html_parser;
import 'package:dio/dio.dart' as dio;
import 'package:html/dom.dart' as html_dom;
// 💡 前回のAppDatabaseが定義されているファイルをインポートしてください
import '../../core/database/app_database.dart';

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
    final dbHelper = AppDatabase.instance;

    for (final assignment in assignmentList) {
      // 1. 科目（subjects）のIDを特定、または新規登録
      int finalSubjectTableId = await _findOrCreateSubject(assignment.subjectName);

      // 2. すでに同じtaskIdの課題が登録されているか確認
      final existingTask = await dbHelper.getRowById(AppTable.tasks, assignment.taskId);

      // データベースに渡すMapデータの作成
      final taskValues = {
        'subject_id': finalSubjectTableId,
        'task_name': assignment.taskName,
        'deadline': assignment.deadline,
        'url': assignment.submissionURL,
        'feeling': assignment.taskresponse, // 元コードの初期値0
        'status': assignment.taskstatus,     // 元コードの初期値0
      };

      if (existingTask == null) {
        // 未登録の場合は、IDを指定して新規挿入 (ID自動生成ではなく、ScombZのtaskIdをそのままidにする)
        final finalValuesWithId = {
          'id': assignment.taskId,
          ...taskValues,
        };
        // 既存のinsertRowは内部でcreated_atなどを自動付与するので、そのまま使えます
        await dbHelper.insertRow(AppTable.tasks, finalValuesWithId);
        print(' ➕ 新規課題を登録しました: ${assignment.taskName}');
      } else {
        // 既に登録済みの場合は、内容を更新
        await dbHelper.updateRow(AppTable.tasks, assignment.taskId, taskValues);
        print(' 🔄 既存の課題を更新しました: ${assignment.taskName}');
      }
    }
    print('✨ すべての課題データの同期が完了しました！');
  }

  /// 科目名から既存の科目IDを探し、なければ新規作成してそのIDを返すヘルパーメソッド
  Future<int> _findOrCreateSubject(String subjectName) async {
    final dbHelper = AppDatabase.instance;
    
    // 全科目を取得して、名前が一致するものを探す
    final allSubjects = await dbHelper.getRows(AppTable.subjects);
    for (final row in allSubjects) {
      if (row['subject_name'] == subjectName) {
        return row['id'] as int;
      }
    }

    // 見つからなかった場合は新規登録
    print(' 🏫 新しい科目を検出したため登録します: $subjectName');
    final newSubjectId = await dbHelper.insertRow(AppTable.subjects, {
      'subject_name': subjectName,
      'is_online': 0,         // 初期値（スクレイピングだけでは不明なため）
      'attendance_count': 0,  // 初期値
      'total_class_count': 0, // 初期値
    });

    return newSubjectId;
  }
}
