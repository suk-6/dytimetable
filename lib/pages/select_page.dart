import 'package:dytimetable/pages/main_page.dart';
import 'package:dytimetable/utils/pref.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import '../firebase/firebase_setup.dart';
import 'package:dytimetable/utils/get.dart';

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SelectPageState createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  String preMode = 'student';
  late String selectedTeacher = '';
  late String selectedGrade = '';
  late String selectedClass = '';
  bool isLoading = false;

  late Future teachers = getTeachers();

  @override
  void initState() {
    teachers = getTeachers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(preMode == 'student' ? '시간표 알림 설정하기' : '교사 설정하기'),
          actions: [
            IconButton(
              icon: const Icon(Icons.compare_arrows),
              onPressed: () {
                setState(() {
                  if (preMode == 'student') {
                    preMode = 'teacher';
                  } else {
                    preMode = 'student';
                  }
                });
              },
            ),
          ],
        ),
        body: Center(
            child: preMode == 'student'
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DropdownButton<String>(
                            hint: const Text('학년 선택'),
                            value: selectedGrade == '' ? null : selectedGrade,
                            onChanged: (String? value) {
                              setState(() {
                                selectedGrade = value!;
                              });
                            },
                            items: List.generate(3, (index) => index + 1)
                                .map((int value) {
                              return DropdownMenuItem<String>(
                                value: value.toString(),
                                child: Text('$value학년'),
                              );
                            }).toList(),
                          ),
                          const SizedBox(width: 20),
                          DropdownButton<String>(
                            hint: const Text('반 선택'),
                            value: selectedClass == '' ? null : selectedClass,
                            onChanged: (String? value) {
                              setState(() {
                                selectedClass = value!;
                              });
                            },
                            items: List.generate(10, (index) => index + 1)
                                .map((int value) {
                              return DropdownMenuItem<String>(
                                value: value.toString(),
                                child: Text('$value반'),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () {
                                if (selectedGrade != '' &&
                                    selectedClass != '') {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  FirebaseAnalytics.instance.logSelectContent(
                                      contentType: 'select_classroom',
                                      itemId: '$selectedGrade-$selectedClass');
                                  subscribeToTopic(
                                          '$selectedGrade-$selectedClass')
                                      .then((value) {
                                        setMode('student');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('설정이 완료되었습니다.'),
                                          ),
                                        );
                                      })
                                      .then((value) => setState(() {
                                            isLoading = false;
                                          }))
                                      .then((value) =>
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const TablePage()),
                                              (route) => false));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('학년과 반을 선택해주세요.'),
                                    ),
                                  );
                                }
                              },
                              child: const Text('설정하기'),
                            ),
                    ],
                  )
                : FutureBuilder(
                    future: teachers,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DropdownButton(
                                hint: const Text('선생님 선택'),
                                value: selectedTeacher == ''
                                    ? null
                                    : selectedTeacher,
                                items: List.generate(snapshot.data!.length - 1,
                                    (index) {
                                  return DropdownMenuItem(
                                    value: (index + 1).toString(),
                                    child: Text(
                                        '${index + 1} ${snapshot.data![index + 1]}'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedTeacher = value.toString();
                                  });
                                }),
                            const SizedBox(height: 20),
                            isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
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
                                        subscribeToTopic(id)
                                            .then((value) {
                                              setMode('teacher');
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text('설정이 완료되었습니다.'),
                                                ),
                                              );
                                            })
                                            .then((value) => setState(() {
                                                  isLoading = false;
                                                }))
                                            .then((value) =>
                                                Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const TablePage()),
                                                    (route) => false));
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('이름을 선택해주세요.'),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text('설정하기'),
                                  ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      } else {
                        return const CircularProgressIndicator();
                      }
                    })));
  }
}
