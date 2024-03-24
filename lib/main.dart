import 'package:dytimetable/select_page.dart';
import "package:flutter/material.dart";
import 'package:dytimetable/firebase_setup.dart';
import 'package:dytimetable/pref.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupFlutterNotifications();
  await initSharedPreferences();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SelectPage(),
    );
  }
}
