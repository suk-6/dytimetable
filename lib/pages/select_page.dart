import 'package:dytimetable/utils/pref.dart';
import 'package:dytimetable/utils/put.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
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
  late String password = '';
  bool isLoading = false;

  late Future teachers = getTeachers();

  @override
  void initState() {
    teachers = getTeachers();
    super.initState();
  }

  Future<void> dialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('비밀번호 입력', textAlign: TextAlign.center),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
              ]);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
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
                  password = '';
                });
                if (preMode == 'student') {
                  dialog().then((value) {
                    checkPassword(password).then((value) {
                      if (value) {
                        setState(() {
                          preMode = 'teacher';
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('교사 모드로 전환되었습니다.'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('비밀번호가 틀렸습니다.'),
                          ),
                        );
                      }
                    });
                  });
                } else {
                  setState(() {
                    preMode = 'student';
                  });
                }
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
                                    setMode('student')
                                        .then((value) {
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
                                            Get.offAllNamed('/table'));
                                  });
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
                                                Get.offAllNamed('/table'));
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
