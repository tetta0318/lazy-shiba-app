import 'package:shared_preferences/shared_preferences.dart';

import '../schedule/SubjectsScraping.dart';
import '../tasks/task_scraping.dart';

/// 認証に関する想定内のエラー（入力不足・認証失敗など）を表す。
/// [message]はそのままUIに表示できる日本語メッセージ。
class AuthenticationException implements Exception {
  final String message;

  const AuthenticationException(this.message);

  @override
  String toString() => message;
}

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

  static const String emptyInputMessage = '学籍番号とパスワードを入力してください。';
  static const String invalidCredentialMessage = '学籍番号とパスワードが正しくありません。';

  /// 入力チェックを行い、ScombZの資格情報を端末内(SharedPreferences)に保存する。
  /// 学籍番号・パスワードのいずれかが未入力の場合は[AuthenticationException]。
  Future<void> saveCredentials({
    required String id,
    required String password,
  }) async {
    if (id.isEmpty || password.isEmpty) {
      throw const AuthenticationException(emptyInputMessage);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('scombz_id', id);
    await prefs.setString('scombz_password', password);
  }

  /// ログイン結果のCookieを検証し、課題・時間割をDBへ初回同期する。
  /// Cookieが取得できていない（＝認証がはじかれた）場合は[AuthenticationException]。
  /// スクレイピングやDB保存に失敗した場合は、その例外をそのまま呼び出し元へ伝える。
  Future<void> completeLogin(String? cookies) async {
    if (cookies == null || cookies.isEmpty) {
      throw const AuthenticationException(invalidCredentialMessage);
    }

    await _syncInitialData(cookies);
  }

  /// ログインで取得したCookieを使い、課題・時間割をDBへ初回同期する。
  Future<void> _syncInitialData(String cookies) async {
    _taskScraping.taskDio.options.headers['Cookie'] = cookies;
    await _taskScraping.getTasks();

    _subjectsScraping.timetableDio.options.headers['Cookie'] = cookies;
    await _subjectsScraping.getSubjectNames();
  }
}