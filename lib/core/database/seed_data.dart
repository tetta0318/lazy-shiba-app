import 'package:lazy_shiba_app/core/database/app_database.dart';

class SeedData {
  SeedData._();

  static Future<void> insertIfEmpty() async {
    final db = await AppDatabase.instance.database;

    await _seedSubjects(db);
    await _seedTasks(db);
    await _seedSchedules(db);

    
  }

  static Future<void> _seedSubjects(dynamic db) async {
    final count = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM subjects',
    );

    if (count.first['count'] != 0) {
      return;
    }

    final now = DateTime.now().toIso8601String();

    await db.insert('subjects', {
      'subject_name': '情報セキュリティ',
      'is_online': 0,
      'attendance_count': 12,
      'total_class_count': 15,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('subjects', {
      'subject_name': 'Java応用プログラミング（1Q）',
      'is_online': 1,
      'attendance_count': 10,
      'total_class_count': 15,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('subjects', {
      'subject_name': '人工知能プログラミング（2Q）',
      'is_online': 0,
      'attendance_count': 8,
      'total_class_count': 15,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('subjects', {
      'subject_name': 'ソフトウェア工学',
      'is_online': 0,
      'attendance_count': 8,
      'total_class_count': 15,
      'created_at': now,
      'updated_at': now,
    });
    
    await db.insert('subjects', {
      'subject_name': 'ソフトウェア開発演習',
      'is_online': 0,
      'attendance_count': 8,
      'total_class_count': 15,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('subjects', {
      'subject_name': '人工知能',
      'is_online': 0,
      'attendance_count': 8,
      'total_class_count': 15,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('subjects', {
      'subject_name': 'データ解析法',
      'is_online': 0,
      'attendance_count': 8,
      'total_class_count': 15,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('subjects', {
      'subject_name': '組込みシステム',
      'is_online': 0,
      'attendance_count': 8,
      'total_class_count': 15,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('subjects', {
      'subject_name': 'ソフトウェア工学',
      'is_online': 0,
      'attendance_count': 8,
      'total_class_count': 15,
      'created_at': now,
      'updated_at': now,
    });

  }

  static Future<void> _seedTasks(dynamic db) async {
    final count = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM tasks',
    );

    if (count.first['count'] != 0) {
      return;
    }

    final now = DateTime.now().toIso8601String();

    await db.insert('tasks', {
      'subject_id': 1,
      'task_name': 'レポート課題２',
      'deadline':
          DateTime.now()
              .add(const Duration(days: 7))
              .toIso8601String(),
      'url': 'https://example.com/report',
      'feeling': 3,
      'status': 0,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('tasks', {
      'subject_id': 2,
      'task_name': '課題（４）',
      'deadline':
          DateTime.now()
              .add(const Duration(days: 3))
              .toIso8601String(),
      'url': null,
      'feeling': 2,
      'status': 0,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('tasks', {
      'subject_id': 3,
      'task_name': '課題1 （事前課題）',
      'deadline':
          DateTime.now()
              .add(const Duration(days: 14))
              .toIso8601String(),
      'url': 'https://example.com/flutter',
      'feeling': 4,
      'status': 1,
      'created_at': now,
      'updated_at': now,
    });
  }

  static Future<void> _seedSchedules(dynamic db) async {
    final count = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM schedules',
    );

    if (count.first['count'] != 0) {
      return;
    }

    final now = DateTime.now().toIso8601String();

    final schedules = [
    {
      'date': '2026-04-02',
      'title': '入学式',
      'genre': '大学行事',
    },
    {
      'date': '2026-04-14',
      'title': '春学期授業開始',
      'genre': '授業',
    },
    {
      'date': '2026-05-17',
      'title': '大宮祭',
      'genre': '大学行事',
    },
    {
      'date': '2026-06-23',
      'title': '学生大会（休講）',
      'genre': '休講',
    },
    {
      'date': '2026-07-29',
      'title': 'TOEIC IP試験',
      'genre': '試験',
    },
    {
      'date': '2026-08-21',
      'title': '春学期成績公開',
      'genre': '成績',
    },
    {
      'date': '2026-09-26',
      'title': '秋学期授業開始',
      'genre': '授業',
    },
    {
      'date': '2026-10-31',
      'title': '芝浦祭',
      'genre': '大学行事',
    },
    {
      'date': '2026-11-04',
      'title': '創立記念日',
      'genre': '大学行事',
    },
    {
      'date': '2026-11-21',
      'title': '秋2ターム授業開始',
      'genre': '授業',
    },
    {
      'date': '2027-01-26',
      'title': 'TOEIC IP試験',
      'genre': '試験',
    },
    {
      'date': '2027-02-12',
      'title': '秋学期成績公開',
      'genre': '成績',
    },
    {
      'date': '2027-03-18',
      'title': '学位記授与式',
      'genre': '大学行事',
    },
  ];

    for (final schedule in schedules) {
      await db.insert('schedules', {
        ...schedule,
        'created_at': now,
        'updated_at': now,
      });
    }
  }
}