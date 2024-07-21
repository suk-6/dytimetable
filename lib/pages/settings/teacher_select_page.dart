import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:get/route_manager.dart';

import 'package:dytimetable/utils/pref.dart';
import 'package:dytimetable/utils/get.dart';

import 'package:dytimetable/widgets/circular_indicator_widget.dart';
import 'package:dytimetable/widgets/dropdown_widget.dart';

import 'package:dytimetable/firebase/firebase.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class TeacherSelectPage extends StatefulWidget {
  const TeacherSelectPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TeacherSelectPageState createState() => _TeacherSelectPageState();
}

class _TeacherSelectPageState extends State<TeacherSelectPage> {
  late String selectedTeacher = '';
  bool isLoading = false;
  bool isAvailable = false;

  late Future teachers = getTeachers();

  @override
  void initState() {
    teachers = getTeachers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: FutureBuilder(
            future: teachers,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20, left: 25, right: 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '교사 설정하기',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 60),
                      MyDropdownBox(
                          width: 0,
                          hint: '교사 선택',
                          value: selectedTeacher == '' ? null : selectedTeacher,
                          onChanged: (String? value) {
                            setState(() {
                              selectedTeacher = value.toString();
                              isAvailable = selectedTeacher != '';
                            });
                          },
                          items:
                              List.generate(snapshot.data!.length - 1, (index) {
                            return (
                              value: (index + 1).toString(),
                              child:
                                  '${index + 1} ${snapshot.data![index + 1]}',
                            );
                          })),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: isLoading
                              ? const MyCircularProgressIndicator()
                              : isAvailable
                                  ? ElevatedButton(
                                      onPressed: () {
                                        if (selectedTeacher != '') {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          final id = 'teacher-$selectedTeacher';
                                          FirebaseAnalytics.instance
                                              .logSelectContent(
                                                  contentType: 'select_teacher',
                                                  itemId: id);
                                          subscribeToTopic(id).then((value) {
                                            setMode('teacher')
                                                .then((value) => setState(() {
                                                      isLoading = false;
                                                    }))
                                                .then((value) =>
                                                    Get.offAllNamed('/'));
                                          });
                                        }
                                      },
                                      style: ButtonStyle(
                                        minimumSize: WidgetStateProperty.all(
                                          const Size(double.infinity, 50),
                                        ),
                                        shape: WidgetStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                        ),
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                Colors.black87),
                                      ),
                                      child: const Text(
                                        '설정하기 ⚙',
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white),
                                      ),
                                    )
                                  : Container(
                                      width: double.infinity,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.black45,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        '필수로 선택해야 합니다!',
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white),
                                      ),
                                    ),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              } else {
                return const MyCircularProgressIndicator();
              }
            },
          ),
        ));
  }
}
