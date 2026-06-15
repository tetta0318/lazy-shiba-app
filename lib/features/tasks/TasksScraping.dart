// // アクセス可能な状態のScombZのHTMLからタスクに必要な情報を取り出すためのコードです。

// import 'package:html/parser.dart' as html_parser;
// import 'package:dio/dio.dart' as dio;
// import 'package:html/dom.dart' as html_dom;

// class Assignment{
//   final int taskId;
//   final int subjectId;
//   final String taskName;
//   final String subjectName;
//   final String deadline;
//   final String submissionURL;
//   final int taskresponse;
//   final int taskstatus;
//   Assignment({
//     required this.taskId,
//     this.subjectId = 0,
//     required this.taskName,
//     required this.subjectName,
//     required this.deadline,
//     required this.submissionURL,
//     this.taskresponse = 0,
//     this.taskstatus = 0,
//   });
// }

// class tasks_scraping{

//   final dio.Dio taskDio = dio.Dio();
//   List<Assignment> assignmentList = [];

//   Future <void> getTasks() async {
    
//     dio.Response response;
//     // HTMLをString型で取得する
//     try {
//       response = await taskDio.get('https://scombz.shibaura-it.ac.jp/lms/task');
//       final String htmlString = response.data.toString();
//       // 取ってきたStringをdocmentオブジェクトに変換する
//       html_dom.Document document = html_parser.parse(htmlString);
//       // タスクの情報を抜き取る
//       List<html_dom.Element> taskElements = document.querySelectorAll('.result_list_line');
//       int idCounter = 1;
//       for(final html_dom.Element row in taskElements){
//           // --- 科目名の取得 ---
//         final html_dom.Element? courseElement = row.querySelector('.tasklist-course');
//         final String subjectName = courseElement?.text.trim() ?? '科目不明';

//         // --- 課題名と提出URLの取得 ---
//         // 「tasklist-title」クラスの中にある「a」タグをピンポイントで探す
//         final html_dom.Element? anchor = row.querySelector('.tasklist-title a');
//         final String taskName = anchor?.text.trim() ?? 'タイトルなし';
//         final String submissionURL = anchor?.attributes['href'] ?? '';

//         // --- 提出期限の取得 --- 
//         // class="deadline" を持っているspanタグを直接狙い撃ち
//         final html_dom.Element? deadlineElement = row.querySelector('.deadline');
//         final String deadline = deadlineElement?.text.trim() ?? '';

//         // クラスに格納
//         final assignment = Assignment(
//           taskId: idCounter++,
//           taskName: taskName,
//           subjectName: subjectName,
//           deadline: deadline,
//           submissionURL: submissionURL,
//         );

//         assignmentList.add(assignment);
//         }
// これ以降の処理はインタフェースが出来上がったらデータベース値を渡すだけに変更
//         print('\n=========================================');
//         print('【解析完了】取得件数: \${assignmentList.length} 件');
//         print('=========================================');

//       for (final assignment in assignmentList) {
//         print('【ID】     \${assignment.taskId}');
//         print('【科目名】 \${assignment.subjectName}');
//         print('【課題名】 \${assignment.taskName}');
//         print('|__ [締切] \${assignment.deadline}');
//         print('|__ [URL]  \${assignment.submissionURL}');
//         print('-----------------------------------------');
//       }
//       print('=========================================\n');
//     } on Exception catch (e) {
//   // TODO
//       print('HTMLの取得に失敗しました: $e');
//     }

//   }
// }


// テスト用の擬似HTMLを用いて、スクレイピングのロジックを完璧に動かすコードです。
import 'package:html/parser.dart' as html_parser;
import 'package:dio/dio.dart' as dio;
import 'package:html/dom.dart' as html_dom;

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
      // 🚀 実際のScombZサーバーにリクエストを投げる
      final dio.Response response = await taskDio.get('https://scombz.shibaura-it.ac.jp/lms/task');
      final String htmlString = response.data.toString();
      
      // 取ってきた生のHTMLをDOMオブジェクトにパース
      html_dom.Document document = html_parser.parse(htmlString);
      
      // タスク行の要素を取得
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
            // パース失敗時は自動カウンター
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

    } on dio.DioException catch (e) {
      print('❌ 課題一覧のHTTP通信に失敗しました: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ 課題一覧のパース処理中にエラーが発生しました: $e');
      rethrow;
    }
  }
}
