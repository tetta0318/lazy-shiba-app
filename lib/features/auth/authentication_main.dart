import 'package:shared_preferences/shared_preferences.dart';

import '../schedule/SubjectsScraping.dart';
import '../tasks/task_scraping.dart';

/// 認証まわりの内部処理を束ねる（main層）。
/// UI(LoginScreen)はこのクラス経由でのみ資格情報の保存や初回同期を行い、
/// SharedPreferencesやスクレイパ（ロジック部）へ直接依存しない。
/// 課題側の[TaskMain]と同様に、main層が既存のロジック部を直接束ねる。
class AuthenticationMain {
  AuthenticationMain({
    TaskScraping? taskScraping,
    SubjectsScraping? subjectsScraping,
  })  : _taskScraping = taskScraping ?? TaskScraping(),
        _subjectsScraping = subjectsScraping ?? SubjectsScraping();

  final TaskScraping _taskScraping;
  final SubjectsScraping _subjectsScraping;

  /// ScombZの資格情報を端末内(SharedPreferences)に保存する。
  Future<void> saveCredentials({
    required String id,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('scombz_id', id);
    await prefs.setString('scombz_password', password);
  }

  /// ログインで取得したCookieを使い、課題・時間割をDBへ初回同期する。
  /// スクレイピングやDB保存に失敗した場合は例外をそのまま呼び出し元へ伝える。
  Future<void> syncInitialData(String cookies) async {
    _taskScraping.taskDio.options.headers['Cookie'] = cookies;
    await _taskScraping.getTasks();

    _subjectsScraping.timetableDio.options.headers['Cookie'] = cookies;
    await _subjectsScraping.getSubjectNames();
  }
}