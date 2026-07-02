import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart'; 
import 'LoginWebviewPage.dart';
import '../../core/database/providers/subject_providers.dart';
import '../schedule/SubjectsScraping.dart';
import '../tasks/TasksScraping.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isObscure = true; 
  String _errorMessage = ''; // 🌟【追加】エラーメッセージを保持する変数

  // 🌟【変更】ダミーの _handleLogin を、Cookie回収＆スクレイピングの _startSync に統合・変更
  Future<void> _handleLogin() async {
    // 1. WebView画面を開き、入力されたIDとパスワードを渡す
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('scombz_id', _idController.text);
    await prefs.setString('scombz_password', _passwordController.text);
    if (!mounted) return;
    final grabbedCookies = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => LoginWebviewPage(
          id: _idController.text,         // コントローラーから直で渡す
          password: _passwordController.text,
        ),
      ),
    );

    // Cookieが取れなかった（キャンセルされた）場合
    if (grabbedCookies == null || grabbedCookies.isEmpty) {
      setState(() {
        _errorMessage = '連携がキャンセルされました。';
      });
      return;
    }

    // 同期処理開始（インジケータを回す）
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 2. 既存のスクレイピングロジックを実行
      // ※クラス名やメソッド名は元のコードのままにしています
      final tasksScraper = TasksScraping();
      tasksScraper.taskDio.options.headers['Cookie'] = grabbedCookies;
      await tasksScraper.getTasks();

      final subjectProvider = SubjectProvider();
      final subjectsScraper = SubjectsScraping(subjectProvider: subjectProvider);
      subjectsScraper.timetableDio.options.headers['Cookie'] = grabbedCookies;
      await subjectsScraper.getSubjectNames();

      if (!mounted) return;

      // 3. すべて成功したら、ホーム画面へ移動（戻れないようにReplacement）
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );

    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '同期中にエラーが発生しました: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.school,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              const Text(
                '怠惰な芝浦学生のための\n成績管理アプリ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // 学籍番号入力欄
              TextField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: '学籍番号 (ScombZ ID)',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // パスワード入力欄
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'パスワード',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
                obscureText: _isObscure, 
              ),
              
              // 🌟【追加】エラーメッセージがある場合のみ表示するエリア
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
              
              const SizedBox(height: 32),

              // ログイン・同期ボタン
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  // 読み込み中はボタンを押せないようにする
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('ScombZ にログイン', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                '※ScombZのログイン情報を入力してください。\n入力された情報は端末内にのみ安全に保存されます。',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}