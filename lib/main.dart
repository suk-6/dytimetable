import 'package:dytimetable/onboarding.dart';
import 'package:dytimetable/table.dart';
import "package:flutter/material.dart";
import 'package:dytimetable/firebase_setup.dart';
import 'package:dytimetable/pref.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupFlutterNotifications();
  await initSharedPreferences();

  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isOnboardingDone = false;

  @override
  Widget build(BuildContext context) {
    getClassroom().then((String? classroom) {
      if (classroom == null) {
        setState(() {
          isOnboardingDone = false;
        });
      } else {
        setState(() {
          isOnboardingDone = true;
        });
      }
    });

    return isOnboardingDone ? const TablePage() : const OnboardingPage();
  }
}
