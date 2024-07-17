import "package:flutter/material.dart";

import 'package:dytimetable/utils/pref.dart';
import 'package:dytimetable/utils/check_update.dart';

import 'package:get/route_manager.dart';

import 'package:dytimetable/pages/main/main_page.dart';
import 'package:dytimetable/pages/settings/onboarding.dart';
import 'package:dytimetable/pages/settings/setting_page.dart';
import 'package:dytimetable/pages/alert/alert_list_page.dart';
import 'package:dytimetable/pages/alert/alert_view_page.dart';
import 'package:dytimetable/pages/alert/alert_send_page.dart';
import 'package:dytimetable/pages/settings/select_page.dart';

import 'package:dytimetable/firebase/firebase.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }

  @override
  void initState() {
    super.initState();
    verifyVersion(context);
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: [
        GetPage(name: '/', page: () => const MainPage()),
        GetPage(name: '/onboarding', page: () => const OnboardingPage()),
        GetPage(name: '/select', page: () => const SelectPage()),
        GetPage(name: '/alert', page: () => const AlertPage()),
        GetPage(name: '/alert-send', page: () => const AlertSendPage()),
        GetPage(name: '/alert-view', page: () => const AlertViewPage()),
        GetPage(name: '/settings', page: () => const SettingPage()),
      ],
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "Pretendard"),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
      ],
    );
  }
}
