import 'package:flutter/material.dart';

import '../../core/database/repositories/subject_repository.dart';
import '../../core/database/repositories/task_repository.dart';
import '../../core/database/models/subject.dart';
import '../../core/database/models/task.dart';


class SubjectDetailPage extends StatefulWidget {

  final int subjectId;

  const SubjectDetailPage({
    super.key,
    required this.subjectId,
  });


  @override
  State<SubjectDetailPage> createState() =>
      _SubjectDetailPageState();

}



class _SubjectDetailPageState
    extends State<SubjectDetailPage> {


  final SubjectRepository _subjectRepository =
      SubjectRepository();

  final TaskRepository _taskRepository =
      TaskRepository();


  Subject? _subject;

  List<Task> _tasks = [];

  bool _isLoading = true;



  @override
  void initState() {

    super.initState();

    _loadData();

  }



  Future<void> _loadData() async {

    try {

      final subjects =
          await _subjectRepository.getSubjects();


      final subject =
          subjects.firstWhere(
            (s) => s.id == widget.subjectId,
          );


      final tasks =
          await _taskRepository.getTasksBySubjectId(
            widget.subjectId,
          );


      if(!mounted) return;


      setState(() {

        _subject = subject;

        _tasks = tasks;

        _isLoading = false;

      });


    } catch(e) {

      if(!mounted) return;


      setState(() {

        _isLoading = false;

      });

    }

  }



  @override
  Widget build(BuildContext context) {


    if(_isLoading){

      return const Scaffold(

        body:Center(

          child:CircularProgressIndicator(),

        ),

      );

    }



    if(_subject == null){

      return const Scaffold(

        body:Center(

          child:Text(
            '科目が見つかりません',
          ),

        ),

      );

    }



    final Subject subject = _subject!;



    final double attendanceRate =
        subject.totalClassCount == 0
        ? 0.0
        : subject.attendanceCount /
          subject.totalClassCount;



    return Scaffold(


      appBar:AppBar(

        backgroundColor:
            Colors.red.shade100,

        title:Text(

          subject.subjectName,

          style:const TextStyle(

            color:Colors.black,

            fontSize:16,

          ),

        ),

      ),



      body:Padding(

        padding:
            const EdgeInsets.all(16),


        child:Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,


          children:[



            const Text(

              '出席率',

              style:TextStyle(

                fontWeight:
                    FontWeight.bold,

              ),

            ),



            const SizedBox(height:10),



            LinearProgressIndicator(

              value:attendanceRate,

              minHeight:20,

            ),



            const SizedBox(height:10),



            Text(

              '出席率 ${(attendanceRate * 100).toStringAsFixed(0)}%',

            ),



            const SizedBox(height:30),



            const Text(

              '課題一覧',

              style:TextStyle(

                fontWeight:
                    FontWeight.bold,

              ),

            ),



            const SizedBox(height:10),



            if(_tasks.isEmpty)

              const Text(
                '登録されている課題はありません',
              )

            else

              ..._tasks.map(

                (task)=>_taskRow(task),

              ),



            const SizedBox(height:30),



            const Text(

              '全体の成績',

              style:TextStyle(

                fontWeight:
                    FontWeight.bold,

              ),

            ),



            const SizedBox(height:10),



            const LinearProgressIndicator(

              value:0.0,

              minHeight:20,

            ),



            const Text(

              'ScombZ同期後に反映',

            ),

          ],

        ),

      ),

    );

  }




  Widget _taskRow(Task task){


    return Padding(

      padding:
          const EdgeInsets.only(
            bottom:10,
          ),


      child:Row(

        children:[


          Expanded(

            child:Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,


              children:[


                Text(

                  task.taskName,

                  style:
                      const TextStyle(

                    fontWeight:
                        FontWeight.bold,

                  ),

                ),



                Text(

                  '締切 ${task.deadline.toString().substring(0,16)}',

                  style:
                      const TextStyle(

                    fontSize:12,

                  ),

                ),

              ],

            ),

          ),



          ElevatedButton(

            onPressed:(){

              ScaffoldMessenger.of(context)
                  .showSnackBar(

                const SnackBar(

                  content:Text(
                    '課題修正機能はScombZ同期後に対応します',
                  ),

                ),

              );

            },


            child:const Text(
              '修正',
            ),

          ),


        ],

      ),

    );

  }

}