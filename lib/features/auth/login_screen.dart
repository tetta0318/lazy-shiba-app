import 'package:flutter/material.dart';
import 'package:lazy_shiba_app/shared/main_layout_screen.dart';

import 'LoginWebviewPage.dart';
import 'authentication_main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthenticationMain _authMain = AuthenticationMain();

  bool _isLoading = false;
  bool _isObscure = true;
  String _errorMessage = '';

  Future<void> _handleLogin() async {
    final id = _idController.text;
    final password = _passwordController.text;

    // 資格情報の保存はmain層(AuthenticationMain)へ委譲する。
    await _authMain.saveCredentials(id: id, password: password);
    if (!mounted) {
      return;
    }

    // Cookie取得はWebView画面(UI)に任せ、戻り値としてCookieを受け取る。
    final grabbedCookies = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => LoginWebviewPage(
          id: id,
          password: password,
        ),
      ),
    );

    if (grabbedCookies == null || grabbedCookies.isEmpty) {
      setState(() {
        _errorMessage = '連携がキャンセルされました。';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 課題・時間割の初回同期もmain層へ委譲する。
      await _authMain.syncInitialData(grabbedCookies);

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
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
          padding: const EdgeInsets.all(32),
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
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'ScombZ にログイン',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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