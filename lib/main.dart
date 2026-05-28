import 'package:flutter/material.dart';

import 'core/database/app_database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lazy Shiba DB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff256f68)),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        useMaterial3: true,
      ),
      home: const DatabasePage(),
    );
  }
}

class TableField {
  const TableField({required this.key, required this.label, this.keyboardType});

  final String key;
  final String label;
  final TextInputType? keyboardType;
}

class EditableTable {
  const EditableTable({
    required this.name,
    required this.label,
    required this.icon,
    required this.orderBy,
    required this.fields,
  });

  final String name;
  final String label;
  final IconData icon;
  final String orderBy;
  final List<TableField> fields;
}

const editableTables = [
  EditableTable(
    name: AppTable.tasks,
    label: '課題',
    icon: Icons.assignment_outlined,
    orderBy: 'due_date ASC, id DESC',
    fields: [
      TableField(key: 'title', label: '課題名'),
      TableField(key: 'subject', label: '科目'),
      TableField(key: 'due_date', label: '締切'),
      TableField(key: 'status', label: '状態'),
      TableField(key: 'memo', label: 'メモ'),
    ],
  ),
  EditableTable(
    name: AppTable.grades,
    label: '成績',
    icon: Icons.school_outlined,
    orderBy: 'subject ASC, id DESC',
    fields: [
      TableField(key: 'subject', label: '科目'),
      TableField(key: 'score', label: '点数', keyboardType: TextInputType.number),
      TableField(
        key: 'max_score',
        label: '満点',
        keyboardType: TextInputType.number,
      ),
      TableField(key: 'term', label: '学期'),
      TableField(key: 'memo', label: 'メモ'),
    ],
  ),
  EditableTable(
    name: AppTable.schedules,
    label: '予定',
    icon: Icons.event_note_outlined,
    orderBy: 'start_at ASC, id DESC',
    fields: [
      TableField(key: 'title', label: '予定名'),
      TableField(key: 'location', label: '場所'),
      TableField(key: 'start_at', label: '開始日時'),
      TableField(key: 'end_at', label: '終了日時'),
      TableField(key: 'memo', label: 'メモ'),
    ],
  ),
];

class DatabasePage extends StatefulWidget {
  const DatabasePage({super.key});

  @override
  State<DatabasePage> createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _database = AppDatabase.instance;
  bool _loading = true;
  List<Map<String, Object?>> _rows = [];

  EditableTable get _currentTable => editableTables[_tabController.index];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: editableTables.length, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) {
          _loadRows();
        }
      });
    _initialize();
  }

  Future<void> _initialize() async {
    await _database.seedIfEmpty();
    await _loadRows();
  }

  Future<void> _loadRows() async {
    setState(() => _loading = true);
    final table = _currentTable;
    final rows = await _database.getRows(table.name, orderBy: table.orderBy);
    if (!mounted) {
      return;
    }
    setState(() {
      _rows = rows;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openEditor([Map<String, Object?>? row]) async {
    final table = _currentTable;
    final controllers = {
      for (final field in table.fields)
        field.key: TextEditingController(text: '${row?[field.key] ?? ''}'),
    };

    final result = await showDialog<Map<String, Object?>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(row == null ? '${table.label}を追加' : '${table.label}を編集'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final field in table.fields)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: controllers[field.key],
                      keyboardType: field.keyboardType,
                      decoration: InputDecoration(labelText: field.label),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop(_buildValues(table, controllers));
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('保存'),
            ),
          ],
        );
      },
    );

    for (final controller in controllers.values) {
      controller.dispose();
    }

    if (result == null) {
      return;
    }

    if (row == null) {
      await _database.insertRow(table.name, result);
    } else {
      await _database.updateRow(table.name, row['id'] as int, result);
    }
    await _loadRows();
  }

  Map<String, Object?> _buildValues(
    EditableTable table,
    Map<String, TextEditingController> controllers,
  ) {
    return {
      for (final field in table.fields)
        field.key: _parseFieldValue(field, controllers[field.key]!.text),
    };
  }

  Object _parseFieldValue(TableField field, String value) {
    final trimmedValue = value.trim();
    if (field.keyboardType == TextInputType.number) {
      return double.tryParse(trimmedValue) ?? 0;
    }
    return trimmedValue;
  }

  Future<void> _deleteRow(Map<String, Object?> row) async {
    final table = _currentTable;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${table.label}を削除'),
          content: const Text('このデータを削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('削除'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await _database.deleteRow(table.name, row['id'] as int);
    await _loadRows();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Lazy Shiba Database'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            for (final table in editableTables)
              Tab(icon: Icon(table.icon), text: table.label),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  '${_currentTable.label}テーブル',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  tooltip: '再読み込み',
                  onPressed: _loadRows,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _rows.isEmpty
                  ? Center(child: Text('${_currentTable.label}データはありません'))
                  : ListView.separated(
                      itemCount: _rows.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final row = _rows[index];
                        return _DatabaseRowCard(
                          table: _currentTable,
                          row: row,
                          onEdit: () => _openEditor(row),
                          onDelete: () => _deleteRow(row),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        tooltip: '${_currentTable.label}を追加',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DatabaseRowCard extends StatelessWidget {
  const _DatabaseRowCard({
    required this.table,
    required this.row,
    required this.onEdit,
    required this.onDelete,
  });

  final EditableTable table;
  final Map<String, Object?> row;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final titleField = table.fields.first;
    final subtitleParts = table.fields
        .skip(1)
        .map((field) => '${field.label}: ${row[field.key] ?? ''}')
        .where((text) => !text.endsWith(': '))
        .toList();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(table.icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${row[titleField.key] ?? ''}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(subtitleParts.join(' / ')),
                  const SizedBox(height: 6),
                  Text(
                    'id: ${row['id']}  updated: ${row['updated_at']}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: '編集',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: '削除',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
