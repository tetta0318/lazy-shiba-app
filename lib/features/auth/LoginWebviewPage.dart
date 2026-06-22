import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginWebviewPage extends StatefulWidget {
  final String id;
  final String password;

  const LoginWebviewPage({
    super.key,
    required this.id,
    required this.password,
  });

  @override
  State<LoginWebviewPage> createState() => _LoginWebviewPageState();
}

class _LoginWebviewPageState extends State<LoginWebviewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学校ポータルにログイン'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) async {
            setState(() => _isLoading = false);

            print('【ページ読込完了】: $url');

            // ─── ステップ1: 最初のログイン選択ページ ───
            if (url.endsWith('/login')) {
              print('➔ 「学内ユーザログイン」ボタンを自動クリックします。');
              await _controller.runJavaScript('''
                (function() {
                  var loginBtn = document.querySelector('a.login-btn') || 
                                 document.querySelector('a[href*="saml/login"]');
                  if (loginBtn) {
                    loginBtn.click();
                  }
                })();
              ''');
            }
            
            // ─── ステップ2: ADFS認証画面（ID・PW入力ページ） ───
            else if (url.contains('adfs') || url.contains('sic.shibaura-it.ac.jp')) {
              print('➔ ADFSログイン画面を検知。IDにドメインを付与して自動入力します。');
              
              // 🌟【ここを修正】
              // 入力された学籍番号（widget.id）に、すでに「@」が含まれているかチェックし、
              // なければ自動で「@sic.shibaura-it.ac.jp」をくっつけます。
              // ※ もし「@sic」だけでよければ、下の文字列を '@sic' に書き換えてください。
              final String rawId = widget.id.trim();
              final String formattedId = rawId.contains('@') 
                  ? rawId 
                  : '$rawId@sic.shibaura-it.ac.jp';

              await _controller.runJavaScript('''
                (function() {
                  var idField = document.getElementById('userNameInput');
                  var pwField = document.getElementById('passwordInput');
                  var submitButton = document.getElementById('submitButton');

                  if (idField && pwField) {
                    // 🌟整形したID（メールアドレス形式）を入力欄にセット
                    idField.value = '$formattedId';
                    pwField.value = '${widget.password}';
                    
                    if (submitButton) {
                      if (typeof Login !== 'undefined' && Login.submitLoginRequest) {
                        Login.submitLoginRequest();
                      } else {
                        submitButton.click();
                      }
                    }
                  }
                })();
              ''');
            }
          },
          onUrlChange: (UrlChange change) async {
            final String? currentUrl = change.url;
            if (currentUrl == null) return;

            print('【URL変化を検知】: $currentUrl');

            if (currentUrl.contains('scombz.shibaura-it.ac.jp/portal/home')) {
              print('🎉 ログイン完了をURL変化から検知しました！Cookieを回収します。');

              final cookieManager = WebViewCookieManager();
              final cookies = await cookieManager.getCookies(
                domain: Uri.parse('https://scombz.shibaura-it.ac.jp'),
              );

              print('--- 取得したCookie一覧 ---');
              String cookieString = '';
              for (var cookie in cookies) {
                print('${cookie.name}=${cookie.value}');
                cookieString += '${cookie.name}=${cookie.value}; ';
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ログインに成功しました！データの同期を開始します。')),
                );
                Navigator.pop(context, cookieString);
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://scombz.shibaura-it.ac.jp/login'));
  }
}
