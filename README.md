# lazy_shiba_app

大学ポータルの情報をスクレイピングして取り込み、課題・成績・予定をまとめて管理できる Flutter アプリです。

## 主な機能
* 大学ポータルへのログイン・認証 (`features/auth`)
* 課題の取得・管理・完了報告 (`features/tasks`)
* 成績・GPA の確認と目標管理 (`features/grades`)
* 履修スケジュールの表示 (`features/schedule`)
* ホーム画面ウィジェットとの連携 (`features/widgets`, Android の `TaskWidgetProvider`)
* SQLite (`sqflite`) によるローカルデータ永続化と `flutter_riverpod` による状態管理

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## セットアップ

```bash
# 依存パッケージの取得
flutter pub get

# アプリの起動 (端末/エミュレータを接続した状態で実行)
flutter run
```

このリポジトリは `.fvmrc` で Flutter バージョンを固定しています。[FVM](https://fvm.app/) を利用している場合は次のように実行してください。

```bash
fvm install
fvm flutter pub get
fvm flutter run
```

## テスト・静的解析

```bash
flutter analyze
flutter test
```

# Version
* Flutter: 3.44.0
* Android SDK: 36
* compileSdk: 36
* targetSdk: 36
* minSdk: 24
* Java: 17

# フォルダ構成
* core/database SQLiteなどアプリ全体で使うDB
* features/auth ログイン・認証
* features/tasks 課題管理
* features/grades 成績管理
* features/schedule 予定管理
* features/widgets ホーム画面やウィジェット関連
* shared 共通UIやテーマ

# 主な使用パッケージ
* flutter_riverpod: 状態管理
* sqflite: ローカルDB (SQLite)
* dio: HTTP通信
* html: 大学ポータルのスクレイピング (HTML解析)
* webview_flutter: ポータルログイン用WebView
* shared_preferences: 簡易データ保存
* home_widget: ホーム画面ウィジェット連携

