import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import ''

class AppTable {
  const AppTable._();

  static const tasks = 'tasks';
  static const subjects = 'subjects';
  static const schedules = 'schedules';
}

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const _databaseName = 'lazy_shiba.db';
  static const _databaseVersion = 1;
  static const _supportedTables = {
    AppTable.tasks,
    AppTable.subjects,
    AppTable.schedules,
  };

  Database? _database;

  Future<Database> get database async {
    final currentDatabase = _database;
    if (currentDatabase != null) {
      return currentDatabase;
    }

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);
    final openedDatabase = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDatabase,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
    _database = openedDatabase;
    return openedDatabase;
  }

/* データベース 型
INTEGER 符号付き整数 -> int
STRING 文字列 -> String
*/

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppTable.tasks} (
        task_id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        task_name TEXT NOT NULL,
        deadline TEXT NOT NULL,
        url TEXT NOT NULL,
        feeling INTEGER NOT NULL,
        STATUS INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(subject_id)
          REFARENCES subjects(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppTable.subjects} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_name TEXT NOT NULL,
        is_online INTEGER NOT NULL,
        attendance_count INTEGER NOT NULL,
        total_class_count INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppTable.schedules} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        title TEXT NOT NULL,
        genre TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<List<Map<String, Object?>>> getRows(
    String table, {
    String? orderBy,
  }) async {
    _checkTable(table);
    final db = await database;
    return db.query(table, orderBy: orderBy);
  }

  Future<int> insertRow(String table, Map<String, Object?> values) async {
    _checkTable(table);
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return db.insert(table, {...values, 'created_at': now, 'updated_at': now});
  }

  Future<int> updateRow(
    String table,
    int id,
    Map<String, Object?> values,
  ) async {
    _checkTable(table);
    final db = await database;
    return db.update(
      table,
      {...values, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteRow(String table, int id) async {
    _checkTable(table);
    final db = await database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countRows(String table) async {
    _checkTable(table);
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM $table');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> seedIfEmpty() async {
    if (await countRows(AppTable.tasks) == 0) {
      await insertRow(AppTable.tasks, {
        'title': '外部設計書の確認',
        'subject': 'ソフトウェア開発演習',
        'due_date': '2026-06-05',
        'status': '進行中',
        'memo': '画面とDB項目の対応を確認する',
      });
      await insertRow(AppTable.tasks, {
        'title': '内部設計書のDB章を作成',
        'subject': 'ソフトウェア開発演習',
        'due_date': '2026-06-12',
        'status': '未着手',
        'memo': 'テーブル定義とCRUD処理をまとめる',
      });
    }

    if (await countRows(AppTable.subjects) == 0) {
      await insertRow(AppTable.subjects, {
        'subject': 'ソフトウェア開発演習',
        'score': 86,
        'max_score': 100,
        'term': '前期',
        'memo': '中間課題',
      });
    }

    if (await countRows(AppTable.schedules) == 0) {
      await insertRow(AppTable.schedules, {
        'title': 'チーム開発ミーティング',
        'location': '演習室',
        'start_at': '2026-06-01 13:00',
        'end_at': '2026-06-01 14:30',
        'memo': 'DB実装方針を共有する',
      });
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db == null) {
      return;
    }
    await db.close();
    _database = null;
  }

  void _checkTable(String table) {
    if (!_supportedTables.contains(table)) {
      throw ArgumentError.value(table, 'table', 'Unsupported database table');
    }
  }
}
