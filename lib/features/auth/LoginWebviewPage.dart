import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginWebviewPage extends StatefulWidget {
  const LoginWebviewPage({super.key});

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
          // 動きがおかしくなった時用のリロードボタン
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
            const Center(child: CircularProgressIndicator()), // 読込中のぐるぐる
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // WebViewの初期設定
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // JavaScriptを有効化
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) async {
            setState(() => _isLoading = false);
          },
          // ✨【確実なURL検知】画面移動や非同期リダイレクトの瞬間をすべてキャッチする
          onUrlChange: (UrlChange change) async {
            final String? currentUrl = change.url;
            if (currentUrl == null) return;

            // 遷移したURLをコンソールに漏らさず出力
            print('【URL変化を検知】: $currentUrl');

            // ログイン完了後のURL（ScombZのトップページなど）に到達したかを検知
            if (currentUrl.contains('scombz.shibaura-it.ac.jp/portal/home')) {
              print('🎉 ログイン完了をURL変化から検知しました！Cookieを回収します。');

              // ブラウザからクッキーマネージャーを呼び出す
              final cookieManager = WebViewCookieManager();
              
              // ScombZのドメインに紐づくクッキーをすべて取得
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
                // 画面下部にポップアップを表示
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ログインに成功しました！データの同期を開始します。')),
                );
                // 前の画面（mainなど）にCookieの文字列を渡して画面を閉じる
                Navigator.pop(context, cookieString);
              }
            }
          },
        ),
      )
      // 学校のログイン開始画面を開く
      ..loadRequest(Uri.parse('https://scombz.shibaura-it.ac.jp/login')); 
  }
}