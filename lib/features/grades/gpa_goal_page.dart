import 'package:flutter/material.dart';
import 'model/gpa_data.dart';

class GpaGoalPage extends StatefulWidget {
  const GpaGoalPage({super.key});

  @override
  State<GpaGoalPage> createState() => _GpaGoalPageState();
}

class _GpaGoalPageState extends State<GpaGoalPage> {
  final TextEditingController _goalController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade100,
        elevation: 0,
        title: Text(
          'GPA: 予想${GpaData.expectedGpa}'
          ' / 目標${GpaData.targetGpa}'
          ' / 累積${GpaData.cumulativeGpa}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            const Text(
              '累積',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Table(
              border: TableBorder.all(),
              children: const [

                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          '2024',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          '2025',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          '2026',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        '前期3.2\n後期3.4',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        '前期3.3\n後期3.5',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        '前期3.4\n後期3.6',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              '目標',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _goalController,
                    decoration:
                        const InputDecoration(
                      hintText:
                          '目標GPAを入力',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: () {
                    if (_goalController
                        .text
                        .isNotEmpty) {
                      setState(() {
                        GpaData.targetGpa =
                            _goalController.text;
                      });
                    }
                  },
                  child: const Text(
                    '修正',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}