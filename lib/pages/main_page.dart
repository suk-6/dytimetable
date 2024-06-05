import 'package:dytimetable/pages/alert_list_page.dart';
import 'package:dytimetable/utils/get.dart';
import 'package:dytimetable/utils/pref.dart';
import 'package:dytimetable/pages/setting_page.dart';
import 'package:dytimetable/utils/tools.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TablePage extends StatefulWidget {
  final int selectedTabIndex;
  const TablePage({super.key, required this.selectedTabIndex});

  @override
  // ignore: library_private_types_in_public_api
  _TablePageState createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  int _index = 0;
  String? classroom;
  String? mode;
  String? selectedTeacher;
  bool isShowMoreMeal = false;
  late Future mealData = getMealData();
  late Future timetableData = getTimeTableData(null);
  late Future teachersList = getTeachers();

  @override
  void initState() {
    _index = widget.selectedTabIndex;
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final snackBar = SnackBar(
          content: Text(
              "${message.notification!.title!}\n${message.notification!.body!}"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });

    getMode().then((value) {
      setState(() {
        mode = value;
        mealData = getMealData();
      });

      if (mode == 'student') {
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

    super.initState();
  }

  double _dragDistance = 0;

  scrollNotification(notification) {
    final containerExtent = notification.metrics.viewportDimension;
    if (notification is ScrollStartNotification) {
      _dragDistance = 0;
    } else if (notification is OverscrollNotification) {
      _dragDistance -= notification.overscroll;
    } else if (notification is ScrollUpdateNotification) {
      _dragDistance -= notification.scrollDelta!;
    }
    var percent = _dragDistance / (containerExtent);
    if (percent <= -0.2) {
      setState(() {
        isShowMoreMeal = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        if (_index == 0)
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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AlertPage()));
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SettingPage()));
          },
        )
      ]),
      body: _index == 0
          ? Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder(
                      future: timetableData,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        FirebaseAnalytics.instance
                            .logEvent(name: "timetable_page");
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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              14,
                                          color: checkDay(index, subIndex) |
                                                  snapshot.data![index]
                                                          [subIndex]
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
                                SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        50),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    DropdownButton(
                                        value: classroom,
                                        items: generateClassroomList(true)
                                            .map((e) {
                                          return DropdownMenuItem(
                                            value: e,
                                            child: Text(e),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            classroom = value;
                                            if (classroom == '교사') {
                                              selectedTeacher =
                                                  getClassroomSync()
                                                      .toString()
                                                      .replaceAll(
                                                          'teacher-', '');
                                              timetableData = getTimeTableData(
                                                  'teacher-$selectedTeacher');
                                            } else {
                                              timetableData =
                                                  getTimeTableData(classroom);
                                            }
                                          });
                                        }),
                                    if (mode == 'teacher' && classroom == '교사')
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              20),
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
                                                      snapshot.data!.length - 1,
                                                      (index) {
                                                    return DropdownMenuItem(
                                                      value: (index + 1)
                                                          .toString(),
                                                      child: Text(
                                                          '${index + 1} ${snapshot.data![index + 1]}'),
                                                    );
                                                  }).toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedTeacher =
                                                          value.toString();
                                                      timetableData =
                                                          getTimeTableData(
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
            )
          : FutureBuilder(
              future: mealData,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData && snapshot.data != []) {
                  return NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification notification) {
                        scrollNotification(notification);
                        return false;
                      },
                      child: RefreshIndicator(
                        onRefresh: () async {
                          FirebaseAnalytics.instance
                              .logEvent(name: "meal_refresh");
                          setState(() {
                            mealData = getMealData();
                            isShowMoreMeal = false;
                          });
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: ListView(
                                  children: List.generate(
                                      isShowMoreMeal ? snapshot.data.length : 1,
                                      (index) {
                                    return Container(
                                      width: 300,
                                      margin: const EdgeInsets.only(
                                          left: 20, right: 20, bottom: 20),
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 213, 212, 212),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 3,
                                            blurRadius: 10,
                                            offset: const Offset(3,
                                                7), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: 13, left: 20),
                                            alignment: const Alignment(-1, 0),
                                            child: Text(
                                              snapshot.data[index][1],
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: "Pretendard",
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          ),
                                          Container(
                                            width: double.maxFinite,
                                            padding: const EdgeInsets.only(
                                                top: 10, left: 20),
                                            child: Text(
                                              snapshot.data[index][2]
                                                  .toString()
                                                  .replaceAll(',', '\n'),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: "Pretendard",
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ));
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart_outlined),
            label: '시간표',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rice_bowl_sharp),
            label: '급식',
          ),
        ],
        selectedItemColor: Colors.amber[800],
        onTap: (index) {
          switch (index) {
            case 0:
              FirebaseAnalytics.instance.logEvent(name: "timetable_page");
              break;
            case 1:
              FirebaseAnalytics.instance.logEvent(name: "meal_page");
              break;
          }
          setState(() {
            _index = index;
          });
        },
      ),
    );
  }
}
