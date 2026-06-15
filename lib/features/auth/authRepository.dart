import 'package:dio/dio.dart';

class AuthRepository {
  final Dio _dio = Dio();
  
  // ログイン状態を保持する変数
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  // ログインを実行するメソッド
  Future<bool> login({required String username, required String password}) async {
    try {
      print('ログイン処理を開始します...');

      // 1. 実際のログインURLや、学校の統合認証システムの挙動に合わせて調整します
      const String loginUrl = 'https://example.com/lms/login'; 

      // 2. ログインフォームに送信するデータ（ScombZなどの仕様に合わせる）
      final Map<String, dynamic> loginData = {
        'username': username,
        'password': password,
        // 必要に応じて、HTMLから事前にパースした _csrf トークンなどもここに含めます
      };

      // 3. POSTリクエストでログインを試行
      final response = await _dio.post(
        loginUrl,
        data: loginData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType, // フォーム送信形式
          followRedirects: true,                         // リダイレクトを追う
        ),
      );

      // 4. ステータスコードやレスポンス内容でログイン成否を判定
      if (response.statusCode == 200) {
        print('ログイン成功！');
        _isLoggedIn = true;
        return true;
      } else {
        print('ログイン失敗: ステータスコード ${response.statusCode}');
        _isLoggedIn = false;
        return false;
      }
    } catch (e) {
      print('ログイン中にエラーが発生しました: $e');
      _isLoggedIn = false;
      return false;
    }
  }

  // ログアウト処理
  Future<void> logout() async {
    // クッキーの削除やセッションのクリアを行う
    _isLoggedIn = false;
    print('ログアウトしました。');
  }

  // スクレイピング側で使い回すための、ログイン済みDioインスタンスを提供する
  Dio get authenticatedDio => _dio;
}