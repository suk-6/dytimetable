import 'package:dytimetable/get.dart';
import 'package:dytimetable/pref.dart';
import 'package:dytimetable/setting_page.dart';
import 'package:dytimetable/tools.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TablePageState createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  int _index = 0;
  // ignore: avoid_init_to_null
  String? classroom = null;
  late Future mealData = getMealData();
  late Future timetableData = getTimeTableData(null);

  @override
  void initState() {
    getClassroom().then((String? value) {
      setState(() {
        classroom = value;
        mealData = getMealData();
        timetableData = getTimeTableData(classroom);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
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
                                          height: 50,
                                          color: checkDay(index, subIndex)
                                              ? Colors.yellow
                                              : null,
                                          child: Text(
                                            snapshot.data![index][subIndex],
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                DropdownButton(
                                    value: classroom,
                                    items: generateClassroomList().map((e) {
                                      return DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        classroom = value;
                                        timetableData =
                                            getTimeTableData(classroom);
                                      });
                                    }),
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
                  return ListView(
                    padding: const EdgeInsets.all(10),
                    children: List.generate(snapshot.data.length, (index) {
                      return Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(snapshot.data[index][1],
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ),
                            ListTile(
                              title: Text(snapshot.data[index][2]
                                  .toString()
                                  .replaceAll(',', '\n')),
                            ),
                          ],
                        ),
                      );
                    }),
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                } else {
                  return const CircularProgressIndicator();
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
          if (index == 0) {
            FirebaseAnalytics.instance.logEvent(name: "timetable_page");
          }
          if (index == 1) {
            FirebaseAnalytics.instance.logEvent(name: "meal_page");
          }
          setState(() {
            _index = index;
          });
        },
      ),
    );
  }
}
