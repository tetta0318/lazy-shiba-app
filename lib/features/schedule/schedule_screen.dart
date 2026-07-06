import 'package:flutter/material.dart';

import '../../core/database/repositories/schedule_repository.dart';
import '../../core/database/models/schedule.dart';

class ScheduleScreen extends StatefulWidget {

  const ScheduleScreen({
    super.key,
  });


  @override
  State<ScheduleScreen> createState() =>
      _ScheduleScreenState();
}


class _ScheduleScreenState
    extends State<ScheduleScreen> {


  final ScheduleRepository _repository =
      ScheduleRepository();


  List<Schedule> _schedules = [];


  bool _isLoading = true;



  @override
  void initState() {
    super.initState();

    _loadSchedules();
  }



  Future<void> _loadSchedules() async {

    try {

      final schedules =
          await _repository.getSchedules();


      if (!mounted) return;


      setState(() {

        _schedules = schedules;

        _isLoading = false;

      });


    } catch(e) {

      if (!mounted) return;


      setState(() {

        _isLoading = false;

      });


      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            '予定の取得に失敗しました',
          ),
        ),
      );

    }

  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(

        title: const Text(
          '予定',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

      ),



      body: _isLoading

          ? const Center(
              child: CircularProgressIndicator(),
            )


          : ListView(

              padding:
                  const EdgeInsets.all(16),


              children: [



                _buildSectionTitle(
                  '直近の予定',
                ),



                Card(

                  elevation: 2,


                  child: _schedules.isEmpty

                      ? const Padding(
                          padding:
                              EdgeInsets.all(16),

                          child: Text(
                            '予定がありません',
                          ),
                        )


                      : Column(

                          children:

                              _schedules
                                  .map(
                                    (schedule) {

                                      return Column(

                                        children: [

                                          _buildScheduleRow(
                                            schedule,
                                          ),


                                          if(schedule !=
                                              _schedules.last)

                                            const Divider(
                                              height: 1,
                                            ),

                                        ],

                                      );

                                    },
                                  )
                                  .toList(),

                        ),

                ),



                const SizedBox(
                  height: 24,
                ),




                _buildSectionTitle(
                  '一番近い休校日',
                ),



                Card(

                  elevation: 2,

                  color:
                      Colors.red.shade50,


                  child: const ListTile(

                    leading:
                        Icon(
                          Icons.event_busy,
                          color: Colors.red,
                        ),


                    title:
                        Text(
                          '休校日データなし',
                          style:
                              TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                        ),


                    subtitle:
                        Text(
                          '今後ScombZ同期予定',
                        ),

                  ),

                ),




                const SizedBox(
                  height: 24,
                ),




                _buildSectionTitle(
                  '直近のテストまでの日数',
                ),



                Card(

                  elevation: 2,

                  color:
                      Colors.orange.shade50,


                  child: const ListTile(

                    leading:
                        Icon(
                          Icons.timer,
                          color:
                              Colors.orange,
                        ),


                    title:
                        Text(
                          'テスト情報なし',
                          style:
                              TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                        ),


                    trailing:
                        Text(
                          '-',
                          style:
                              TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                        ),

                  ),

                ),


              ],

            ),

    );

  }





  Widget _buildSectionTitle(
      String title) {


    return Padding(

      padding:
          const EdgeInsets.only(
            left: 4,
            bottom: 8,
          ),


      child: Text(

        title,

        style:
            const TextStyle(

              fontSize: 16,

              fontWeight:
                  FontWeight.bold,

            ),

      ),

    );

  }







  Widget _buildScheduleRow(
      Schedule schedule) {


    return Padding(

      padding:
          const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),


      child: Row(

        children: [


          SizedBox(

            width: 100,


            child: Text(

              '${schedule.date.month}/${schedule.date.day}',


              style:
                  const TextStyle(

                    fontWeight:
                        FontWeight.bold,


                    color:
                        Colors.blueGrey,

                  ),

            ),

          ),



          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,


              children: [


                Text(

                  schedule.title,

                  style:
                      const TextStyle(

                        fontSize: 15,

                      ),

                ),



                Text(

                  schedule.genre,


                  style:
                      const TextStyle(

                        fontSize: 12,

                        color:
                            Colors.grey,

                      ),

                ),


              ],

            ),

          ),


        ],

      ),

    );

  }

}

/*class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('予定', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. 直近の予定エリア（ScombZからの課題や固定テスト等）
          _buildSectionTitle('直近の予定'),
          Card(
            elevation: 2,
            child: Column(
              children: [
                _buildScheduleRow('明日', 'ソフトウェア開発演習 課題提出'),
                const Divider(height: 1),
                _buildScheduleRow('１週間後', 'アルゴリズムとデータ構造 小テスト'),
                const Divider(height: 1),
                _buildScheduleRow('１か月後', '前期中間テスト期間'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. 一番近い休校日エリア（固定のスケジュール）
          _buildSectionTitle('一番近い休校日'),
          Card(
            elevation: 2,
            color: Colors.red.shade50,
            child: const ListTile(
              leading: Icon(Icons.event_busy, color: Colors.red),
              title: Text('5月23日（土）', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('週末・休校'),
            ),
          ),
          const SizedBox(height: 24),

          // 3. 直近のテストまでの日数エリア（固定のスケジュール）
          _buildSectionTitle('直近のテストまでの日数'),
          Card(
            elevation: 2,
            color: Colors.orange.shade50,
            child: const ListTile(
              leading: Icon(Icons.timer, color: Colors.orange),
              title: Text('前期中間テスト', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text(
                'あと 14 日', 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ),
          ),
        ],
      ),
      // ユーザーによる手動追加を廃止したため、FloatingActionButtonは削除しています
    );
  }

  // セクションのタイトルを見栄えよく表示するための共通Widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 明日・1週間後・1か月後のリスト行を作るための共通Widget
  Widget _buildScheduleRow(String period, String eventTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              period,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
          ),
          Expanded(
            child: Text(
              eventTitle,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}*/

