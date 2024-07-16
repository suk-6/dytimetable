import 'package:dytimetable/pages/alert_view_page.dart';
import "package:flutter/material.dart";

import 'package:dytimetable/utils/pref.dart';
import 'package:dytimetable/utils/check_update.dart';

import 'package:get/route_manager.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:dytimetable/pages/onboarding.dart';
import 'package:dytimetable/pages/setting_page.dart';
import 'package:dytimetable/pages/alert_list_page.dart';
import 'package:dytimetable/pages/alert_send_page.dart';
import 'package:dytimetable/pages/select_page.dart';
import 'package:dytimetable/pages/main_page.dart';

import 'package:dytimetable/firebase/firebase_setup.dart';
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
  late bool isOnboardingDone = false;

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['click_action'] == 'notice') {
      Get.toNamed('/alert');
    } else if (message.data['click_action'] == 'url') {
      launchUrl(Uri.parse(message.data['data']!));
    } else if (message.data['click_action'] == 'meal') {
      Get.toNamed('/meal');
    }
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
        GetPage(name: '/onboarding', page: () => const OnboardingPage()),
        GetPage(name: '/select', page: () => const SelectPage()),
        GetPage(
            name: '/table',
            page: () => const TablePage(
                  selectedTabIndex: 0,
                )),
        GetPage(
            name: '/meal',
            page: () => const TablePage(
                  selectedTabIndex: 1,
                )),
        GetPage(name: '/alert', page: () => const AlertPage()),
        GetPage(name: '/alert-send', page: () => const AlertSendPage()),
        GetPage(name: '/alert/view', page: () => const AlertViewPage()),
        GetPage(name: '/settings', page: () => const SettingPage()),
      ],
      initialRoute: '/table',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "Pretendard"),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
      ],
    );
  }
}
