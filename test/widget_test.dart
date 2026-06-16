import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_shiba_app/main.dart';

void main() {
  test('database management tables are registered', () {
    expect(editableTables.map((table) => table.label), ['課題', '成績', '予定']);
  });
}
