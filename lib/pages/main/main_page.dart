import 'package:flutter/material.dart';

import 'package:get/route_manager.dart';

import 'package:dytimetable/pages/main/meal_page.dart';
import 'package:dytimetable/pages/main/table_page.dart';

import 'package:dytimetable/utils/tools.dart';
import 'package:dytimetable/utils/pref.dart';

import 'package:dytimetable/widgets/bottom_navigation_bar_widget.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final screens = [
    const TablePage(),
    const MealPage(),
  ];

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
        debugPrint(value);
        if (value == null) {
          Get.offAllNamed('/onboarding');
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
