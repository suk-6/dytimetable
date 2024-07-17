import 'package:flutter/material.dart';

import 'package:dytimetable/pages/main/meal_page.dart';
import 'package:dytimetable/pages/main/table_page.dart';

import 'package:dytimetable/widgets/bottom_navigation_bar_widget.dart';

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
