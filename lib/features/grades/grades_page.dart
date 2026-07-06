import 'package:flutter/material.dart';

import 'gpa_goal_page.dart';
import 'subject_detail_page.dart';

import 'model/gpa_data.dart';

import '../../core/database/repositories/subject_repository.dart';
import '../../core/database/models/subject.dart';



class GradesPage extends StatefulWidget {

  const GradesPage({super.key});


  @override
  State<GradesPage> createState() =>
      _GradesPageState();

}



class _GradesPageState extends State<GradesPage> {


  final SubjectRepository _repository =
      SubjectRepository();


  List<Subject> _subjects = [];


  bool _isLoading = true;



  @override
  void initState(){

    super.initState();

    _loadSubjects();

  }



  Future<void> _loadSubjects() async {


    try{


      final subjects =
          await _repository.getSubjects();



      if(!mounted) return;



      setState((){

        _subjects = subjects;

        _isLoading = false;

      });



    }catch(e){


      if(!mounted) return;



      setState((){

        _isLoading = false;

      });



      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:Text(
            '科目取得に失敗しました',
          ),

        ),

      );

    }

  }




  @override
  Widget build(BuildContext context){


    return Scaffold(


      appBar:AppBar(

        backgroundColor:
            Colors.red.shade100,


        title:Row(

          children:[


            Expanded(

              child:Text(

                'GPA: 予想${GpaData.expectedGpa}'
                ' / 目標${GpaData.targetGpa}'
                ' / 累積${GpaData.cumulativeGpa}',


                style:const TextStyle(

                  fontSize:16,

                  fontWeight:
                      FontWeight.bold,

                  color:Colors.black,

                ),

              ),

            ),



            TextButton(

              onPressed:() async{


                await Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder:(_)=>
                        const GpaGoalPage(),

                  ),

                );


                setState((){});


              },


              child:const Text(

                '詳細',

                style:TextStyle(

                  color:Colors.red,

                ),

              ),

            ),

          ],

        ),

      ),



      body:_isLoading


      ? const Center(

          child:CircularProgressIndicator(),

        )


      :ListView.builder(


          padding:
              const EdgeInsets.all(16),


          itemCount:
              _subjects.length,


          itemBuilder:(context,index){


            final subject =
                _subjects[index];



            return Card(


              margin:
                  const EdgeInsets.only(
                    bottom:12,
                  ),



              child:ListTile(


                title:Text(

                  subject.subjectName,

                  style:
                      const TextStyle(

                    fontWeight:
                        FontWeight.bold,

                  ),

                ),



                trailing:
                    const Icon(
                      Icons.chevron_right,
                    ),



                onTap:(){


                  if(subject.id == null){

                    return;

                  }



                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder:(_)=>

                          SubjectDetailPage(

                            subjectId:
                                subject.id!,

                          ),

                    ),

                  );


                },


              ),

            );


          },

        ),

    );

  }

}