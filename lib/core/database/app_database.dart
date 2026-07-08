import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _ensureSchema(db);
      },
      onOpen: (db) async {
        await _ensureSchema(db);
      },
    );

    _database = openedDatabase;
    return openedDatabase;
  }

  Future<void> _ensureSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${AppTable.subjects} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_name TEXT NOT NULL,
        is_online INTEGER NOT NULL,
        attendance_count INTEGER NOT NULL,
        total_class_count INTEGER NOT NULL,
        day_of_week INTEGER,
        period INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${AppTable.tasks} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        task_name TEXT NOT NULL,
        deadline TEXT NOT NULL,
        url TEXT,
        feeling INTEGER NOT NULL,
        status INTEGER NOT NULL,
        completed_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(subject_id)
          REFERENCES ${AppTable.subjects}(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${AppTable.schedules} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        title TEXT NOT NULL,
        genre TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await _ensureColumns(
      db,
      AppTable.subjects,
      const {
        'subject_name': "TEXT NOT NULL DEFAULT ''",
        'is_online': 'INTEGER NOT NULL DEFAULT 0',
        'attendance_count': 'INTEGER NOT NULL DEFAULT 0',
        'total_class_count': 'INTEGER NOT NULL DEFAULT 0',
        'day_of_week': 'INTEGER',
        'period': 'INTEGER',
        'created_at': "TEXT NOT NULL DEFAULT '1970-01-01T00:00:00.000'",
        'updated_at': "TEXT NOT NULL DEFAULT '1970-01-01T00:00:00.000'",
      },
    );
    await _ensureColumns(
      db,
      AppTable.tasks,
      const {
        'subject_id': 'INTEGER NOT NULL DEFAULT 1',
        'task_name': "TEXT NOT NULL DEFAULT ''",
        'deadline': "TEXT NOT NULL DEFAULT '1970-01-01T00:00:00.000'",
        'url': 'TEXT',
        'feeling': 'INTEGER NOT NULL DEFAULT 0',
        'status': 'INTEGER NOT NULL DEFAULT 0',
        'completed_at': 'TEXT',
        'created_at': "TEXT NOT NULL DEFAULT '1970-01-01T00:00:00.000'",
        'updated_at': "TEXT NOT NULL DEFAULT '1970-01-01T00:00:00.000'",
      },
    );
    await _normalizeTasksTable(db);
    await _ensureColumns(
      db,
      AppTable.schedules,
      const {
        'date': "TEXT NOT NULL DEFAULT '1970-01-01T00:00:00.000'",
        'title': "TEXT NOT NULL DEFAULT ''",
        'genre': "TEXT NOT NULL DEFAULT ''",
        'created_at': "TEXT NOT NULL DEFAULT '1970-01-01T00:00:00.000'",
        'updated_at': "TEXT NOT NULL DEFAULT '1970-01-01T00:00:00.000'",
      },
    );
  }

  Future<void> _ensureColumns(
    Database db,
    String table,
    Map<String, String> columns,
  ) async {
    final existingColumns = await _getColumnNames(db, table);
    for (final entry in columns.entries) {
      if (existingColumns.contains(entry.key)) {
        continue;
      }
      await db.execute(
        'ALTER TABLE $table ADD COLUMN ${entry.key} ${entry.value}',
      );
    }
  }

  Future<Set<String>> _getColumnNames(Database db, String table) async {
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    return rows.map((row) => row['name'].toString()).toSet();
  }

  Future<void> _normalizeTasksTable(Database db) async {
    final columns = await _getColumnNames(db, AppTable.tasks);
    if (!columns.contains('title')) {
      return;
    }

    const legacyTable = 'tasks_legacy_migration';
    await db.execute('PRAGMA foreign_keys = OFF');
    await db.execute('DROP TABLE IF EXISTS $legacyTable');
    await db.execute('ALTER TABLE ${AppTable.tasks} RENAME TO $legacyTable');
    await db.execute('''
      CREATE TABLE ${AppTable.tasks} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        task_name TEXT NOT NULL,
        deadline TEXT NOT NULL,
        url TEXT,
        feeling INTEGER NOT NULL,
        status INTEGER NOT NULL,
        completed_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(subject_id)
          REFERENCES ${AppTable.subjects}(id)
      )
    ''');

    final legacyColumns = await _getColumnNames(db, legacyTable);
    await db.execute('''
      INSERT OR IGNORE INTO ${AppTable.tasks} (
        id,
        subject_id,
        task_name,
        deadline,
        url,
        feeling,
        status,
        completed_at,
        created_at,
        updated_at
      )
      SELECT
        ${_legacyColumn(legacyColumns, 'id', fallback: 'NULL')},
        CASE
          WHEN CAST(${_legacyColumn(legacyColumns, 'subject_id', fallback: '1')} AS INTEGER) > 0
            THEN CAST(${_legacyColumn(legacyColumns, 'subject_id', fallback: '1')} AS INTEGER)
          ELSE 1
        END,
        COALESCE(
          NULLIF(${_legacyColumn(legacyColumns, 'task_name')}, ''),
          NULLIF(${_legacyColumn(legacyColumns, 'title')}, ''),
          ''
        ),
        COALESCE(
          NULLIF(${_legacyColumn(legacyColumns, 'deadline')}, ''),
          '1970-01-01T00:00:00.000'
        ),
        NULLIF(${_legacyColumn(legacyColumns, 'url')}, ''),
        COALESCE(CAST(${_legacyColumn(legacyColumns, 'feeling', fallback: '0')} AS INTEGER), 0),
        COALESCE(CAST(${_legacyColumn(legacyColumns, 'status', fallback: '0')} AS INTEGER), 0),
        NULLIF(${_legacyColumn(legacyColumns, 'completed_at')}, ''),
        COALESCE(
          NULLIF(${_legacyColumn(legacyColumns, 'created_at')}, ''),
          '1970-01-01T00:00:00.000'
        ),
        COALESCE(
          NULLIF(${_legacyColumn(legacyColumns, 'updated_at')}, ''),
          '1970-01-01T00:00:00.000'
        )
      FROM $legacyTable
    ''');
    await db.execute('DROP TABLE $legacyTable');
    await db.execute('PRAGMA foreign_keys = ON');
  }

  String _legacyColumn(
    Set<String> columns,
    String column, {
    String fallback = "''",
  }) {
    return columns.contains(column) ? column : fallback;
  }

  Future<List<Map<String, Object?>>> getRows(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    _checkTable(table);
    final db = await database;

    return db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<Map<String, Object?>?> getRowById(
    String table,
    int id,
  ) async {
    _checkTable(table);
    final db = await database;

    final result = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<int> insertRow(
    String table,
    Map<String, Object?> values,
  ) async {
    _checkTable(table);
    final db = await database;

    final now = DateTime.now().toIso8601String();

    return db.insert(
      table,
      {
        ...values,
        'created_at': now,
        'updated_at': now,
      },
    );
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
      {
        ...values,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteRow(
    String table,
    int id,
  ) async {
    _checkTable(table);
    final db = await database;

    return db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> countRows(String table) async {
    _checkTable(table);
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM $table',
    );

    return Sqflite.firstIntValue(result) ?? 0;
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
      throw ArgumentError.value(
        table,
        'table',
        'Unsupported database table',
      );
    }
  }
}
