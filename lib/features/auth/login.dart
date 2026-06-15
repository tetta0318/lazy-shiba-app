import 'package:flutter/material.dart';
import '../home/home_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  
  // 【追加】パスワードを隠すかどうかを管理する変数（初期値はtrue＝隠す）
  bool _isObscure = true; 

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
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

              // 【変更】パスワード入力欄
              TextField(
                controller: _passwordController,
                // 変数を使うため、InputDecorationの前の const を外しています
                decoration: InputDecoration(
                  labelText: 'パスワード',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  // 【追加】入力欄の右端に配置するアイコンボタン
                  suffixIcon: IconButton(
                    // _isObscure の状態（true/false）に合わせてアイコンを切り替える
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      // ボタンが押されたら、_isObscure の true/false を反転させて画面を更新する
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
                // 【変更】固定の true ではなく、変数と連動させる
                obscureText: _isObscure, 
              ),
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