import 'package:flutter/material.dart';

import 'package:get/route_manager.dart';

import 'package:dytimetable/utils/get.dart';
import 'package:dytimetable/utils/pref.dart';
import 'package:dytimetable/utils/tools.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// ignore: must_be_immutable
class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TablePageState createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  String? classroom;
  String? mode;
  String? selectedTeacher;
  late Future timetableData = getTimeTableData(null);
  late Future teachersList = getTeachers();

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final snackBar = SnackBar(
          content: Text(
              "${message.notification!.title!}\n${message.notification!.body!}"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });

    migrateData().then((value) {
      getMode().then((value) {
        setState(() {
          mode = value;
          debugPrint(mode);
          if (mode == null) {
            Get.offAllNamed('/onboarding');
          } else if (mode == 'student') {
            getClassroom().then((String? classroomData) {
              setState(() {
                classroom = classroomData;
                timetableData = getTimeTableData(classroom);
              });
            });
          } else if (mode == 'teacher') {
            setState(() {
              classroom = '교사';
              selectedTeacher =
                  getClassroomSync().toString().replaceAll('teacher-', '');
              timetableData = getTimeTableData('teacher-$selectedTeacher');
            });
          }
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            FirebaseAnalytics.instance.logEvent(name: "timetable_refresh");
            setState(() {
              if (classroom == '교사') {
                timetableData = getTimeTableData('teacher-$selectedTeacher');
              } else {
                timetableData = getTimeTableData(classroom);
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            Get.toNamed('/alert');
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Get.toNamed('/settings');
          },
        )
      ]),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          FutureBuilder(
            future: timetableData,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              FirebaseAnalytics.instance.logEvent(name: "timetable_page");
              if (snapshot.hasData) {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Table(
                        border: TableBorder.all(),
                        children: List.generate(
                          snapshot.data!.length,
                          (index) => TableRow(
                            children: List.generate(
                              snapshot.data![index].length,
                              (subIndex) => Container(
                                alignment: Alignment.center,
                                height: MediaQuery.of(context).size.height / 14,
                                color: checkDay(index, subIndex) |
                                        snapshot.data![index][subIndex]
                                            .contains('@')
                                    ? Colors.yellow
                                    : null,
                                child: Text(
                                  snapshot.data![index][subIndex]
                                      .replaceAll('@', ''),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: "Pretendard",
                                      fontWeight: FontWeight.w300),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DropdownButton(
                              value: classroom,
                              items: generateClassroomList(true).map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  classroom = value;
                                  if (classroom == '교사') {
                                    selectedTeacher = getClassroomSync()
                                        .toString()
                                        .replaceAll('teacher-', '');
                                    timetableData = getTimeTableData(
                                        'teacher-$selectedTeacher');
                                  } else {
                                    timetableData = getTimeTableData(classroom);
                                  }
                                });
                              }),
                          if (mode == 'teacher' && classroom == '교사')
                            SizedBox(
                                width: MediaQuery.of(context).size.width / 20),
                          if (mode == 'teacher' && classroom == '교사')
                            FutureBuilder(
                                future: teachersList,
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    return DropdownButton(
                                        hint: const Text('선생님 선택'),
                                        value: selectedTeacher == ''
                                            ? null
                                            : selectedTeacher,
                                        items: List.generate(
                                            snapshot.data!.length - 1, (index) {
                                          return DropdownMenuItem(
                                            value: (index + 1).toString(),
                                            child: Text(
                                                '${index + 1} ${snapshot.data![index + 1]}'),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedTeacher = value.toString();
                                            timetableData = getTimeTableData(
                                                'teacher-$selectedTeacher');
                                          });
                                        });
                                  }
                                  return const SizedBox();
                                }),
                        ],
                      ),
                    ]);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              } else {
                return const CircularProgressIndicator();
              }
            },
          )
        ]),
      ),
    );
  }
}
