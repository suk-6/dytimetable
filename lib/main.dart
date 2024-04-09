import 'package:dytimetable/onboarding.dart';
import 'package:dytimetable/pages/main_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import "package:flutter/material.dart";
import 'package:dytimetable/firebase/firebase_setup.dart';
import 'package:dytimetable/utils/pref.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupFirebase();
  await initSharedPreferences();
  FirebaseAnalytics.instance.logAppOpen();

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

    return MaterialApp(
      home: isOnboardingDone ? const TablePage() : const OnboardingPage(),
      theme: ThemeData(fontFamily: "Pretendard"),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
      ],
    );
  }
}
