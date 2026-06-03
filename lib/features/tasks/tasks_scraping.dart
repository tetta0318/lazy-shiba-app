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
  final int subjectId;
  final String taskName;
  final String subjectName;
  final String deadline;
  final String submissionURL;
  final int taskresponse;
  final int taskstatus;

  Assignment({
    required this.taskId,
    this.subjectId = 0,
    required this.taskName,
    required this.subjectName,
    required this.deadline,
    required this.submissionURL,
    this.taskresponse = 0,
    this.taskstatus = 0,
  });
}

class tasks_scraping {
  final dio.Dio taskDio = dio.Dio();
  List<Assignment> assignmentList = [];

  Future<void> getTasks() async {
    // リストを一度空にする（再実行時の重複防止）
    assignmentList.clear();

    // 1. テスト用の擬似HTML（ScombZの課題一覧を想定したモックデータ）
    final String mockHtmlString = '''
    <html>
      <body>
        <div class="result_list_line">
          <div class="tasklist-course">オブジェクト指向プログラミング演習 (A)</div>
          <div class="tasklist-title">
            <a href="/lms/task/submit/11111">第10回 課題：Javaクラス設計</a>
          </div>
          <span class="deadline">2026/06/10 23:59</span>
        </div>
        <div class="result_list_line">
          <div class="tasklist-course">データベースシステム論</div>
          <div class="tasklist-title">
            <a href="/lms/task/submit/22222">中間レポート（SQLクエリの最適化）</a>
          </div>
          <span class="deadline">2026/06/15 18:00</span>
        </div>
        <div class="result_list_line">
          <div class="tasklist-course">オペレーティングシステム</div>
          <div class="tasklist-title">
            <a href="/lms/task/submit/33333">ミニテスト（プロセス同期について）</a>
          </div>
          <span class="deadline">2026/06/20 12:00</span>
        </div>
      </body>
    </html>
    ''';

    try {
      // 2. 取ってきたStringをdocumentオブジェクトに変換する
      html_dom.Document document = html_parser.parse(mockHtmlString);
      
      // 3. タスクの情報を抜き取る（あなたが書いた完璧なロジック）
      List<html_dom.Element> taskElements = document.querySelectorAll('.result_list_line');
      int idCounter = 1;
      
      for (final html_dom.Element row in taskElements) {
        // --- 科目名の取得 ---
        final html_dom.Element? courseElement = row.querySelector('.tasklist-course');
        final String subjectName = courseElement?.text.trim() ?? '科目不明';

        // --- 課題名と提出URLの取得 ---
        final html_dom.Element? anchor = row.querySelector('.tasklist-title a');
        final String taskName = anchor?.text.trim() ?? 'タイトルなし';
        final String submissionURL = anchor?.attributes['href'] ?? '';

        // --- 提出期限の取得 --- 
        final html_dom.Element? deadlineElement = row.querySelector('.deadline');
        final String deadline = deadlineElement?.text.trim() ?? '';

        // クラス（構造体）に格納
        final assignment = Assignment(
          taskId: idCounter++,
          taskName: taskName,
          subjectName: subjectName,
          deadline: deadline,
          submissionURL: submissionURL,
        );

        assignmentList.add(assignment);
      }

    } on Exception catch (e) {
      print('HTMLの取得に失敗しました: \$e');
    }
  }
}
