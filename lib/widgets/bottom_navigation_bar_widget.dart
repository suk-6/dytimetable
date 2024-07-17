import 'package:flutter/material.dart';

import 'package:firebase_analytics/firebase_analytics.dart';

class MyBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MyBottomNavigationBar(
      {super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            FirebaseAnalytics.instance.logEvent(name: "timetable_page");
            break;
          case 1:
            FirebaseAnalytics.instance.logEvent(name: "meal_page");
            break;
        }
        onTap(index);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.table_chart_outlined),
          label: '시간표',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.rice_bowl_sharp),
          label: '급식',
        ),
      ],
      selectedItemColor:
          Colors.amber[800], // TODO: Select the selectedItemColor
    );
  }
}
