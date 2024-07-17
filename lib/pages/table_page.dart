import 'package:flutter/material.dart';

import 'package:get/route_manager.dart';

import 'package:dytimetable/utils/get.dart';
import 'package:dytimetable/utils/pref.dart';
import 'package:dytimetable/utils/tools.dart';

import 'package:dytimetable/widgets/circular_indicator_widget.dart';

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
  String? grade;
  String? classroom;
  String? mode;
  String? selectedTeacher;
  late Future teachersList = getTeachers();
  late Future timetableData = getTimeTableData(null);

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
                grade = classroomData?.split('-')[0];
                classroom = classroomData?.split('-')[1];
                timetableData = getTimeTableData(classroomData);
              });
            });
          } else if (mode == 'teacher') {
            setState(() {
              grade = '교사';
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
              if (grade == '교사') {
                timetableData = getTimeTableData('teacher-$selectedTeacher');
              } else {
                timetableData = getTimeTableData('$grade-$classroom');
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
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Row(
            children: [
              SizedBox(width: MediaQuery.of(context).size.width / 30),
              DropdownButton(
                  value: grade,
                  items: List.generate(mode == 'teacher' ? 4 : 3, (i) {
                    if (i == 3) {
                      return const DropdownMenuItem(
                        value: '교사',
                        child: Text('교사'),
                      );
                    }

                    String index = (i + 1).toString();
                    return DropdownMenuItem(
                      value: index,
                      child: Text('$index학년'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      if (grade == '교사') classroom = '1';
                      grade = value;
                      if (grade == '교사') {
                        selectedTeacher = getClassroomSync()
                            .toString()
                            .replaceAll('teacher-', '');
                        timetableData =
                            getTimeTableData('teacher-$selectedTeacher');
                      } else {
                        timetableData = getTimeTableData('$grade-$classroom');
                      }
                    });
                  }),
              SizedBox(width: MediaQuery.of(context).size.width / 30),
              grade == '교사'
                  ? FutureBuilder(
                      future: teachersList,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          return DropdownButton(
                              value: selectedTeacher,
                              items:
                                  List.generate(snapshot.data!.length - 1, (i) {
                                int index = i + 1;
                                return DropdownMenuItem(
                                  value: index.toString(),
                                  child:
                                      Text('$index ${snapshot.data![index]}'),
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
                      })
                  : DropdownButton(
                      value: classroom,
                      items: List.generate(10, (i) {
                        String index = (i + 1).toString();
                        return DropdownMenuItem(
                          value: index,
                          child: Text('$index반'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          classroom = value;
                          timetableData = getTimeTableData('$grade-$classroom');
                        });
                      })
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height / 200),
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
                    ]);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              } else {
                return const MyCircularProgressIndicator();
              }
            },
          )
        ]),
      ),
    );
  }
}
