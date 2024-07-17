import 'package:flutter/material.dart';

import 'package:get/route_manager.dart';

import 'package:dytimetable/utils/get.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// ignore: must_be_immutable
class MealPage extends StatefulWidget {
  const MealPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MealPageState createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  bool isShowMoreMeal = false;
  late Future mealData = getMealData();

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final snackBar = SnackBar(
          content: Text(
              "${message.notification!.title!}\n${message.notification!.body!}"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });

    setState(() {
      mealData = getMealData();
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
      body: FutureBuilder(
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
                    FirebaseAnalytics.instance.logEvent(name: "meal_refresh");
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
                                padding: const EdgeInsets.only(bottom: 15),
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 213, 212, 212),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 3,
                                      blurRadius: 10,
                                      offset: const Offset(
                                          3, 7), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
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
        },
      ),
    );
  }
}
