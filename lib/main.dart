import "package:flutter/material.dart";
import 'package:dytimetable/onboarding.dart';
import 'package:dytimetable/pages/alert_list_page.dart';
import 'package:dytimetable/pages/main_page.dart';
import 'package:dytimetable/utils/tools.dart';
import 'package:dytimetable/utils/pref.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_version_update/app_version_update.dart';
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
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const AlertPage()));
    } else if (message.data['click_action'] == 'url') {
      launchUrl(Uri.parse(message.data['data']!));
    }
  }

  void _verifyVersion() async {
    await AppVersionUpdate.checkForUpdates(
      appleId: '6479954739',
      playStoreId: 'com.dukyoung.dytimetable',
      country: 'kr',
    ).then((result) async {
      if (result.canUpdate!) {
        await AppVersionUpdate.showAlertUpdate(
          appVersionResult: result,
          context: context,
          mandatory: true,
          backgroundColor: Colors.white,
          title: '새 업데이트가 있습니다.',
          titleTextStyle: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w600, fontSize: 24.0),
          content: '최신 버전으로 업데이트 해주세요.',
          contentTextStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
          updateButtonText: '업데이트',
          updateButtonStyle: ElevatedButton.styleFrom(
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          cancelButtonText: '나중에',
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _verifyVersion();
    setupInteractedMessage();

    migrateData().then((value) {
      getMode().then((value) {
        debugPrint(value);
        if (value == null) {
          setState(() {
            isOnboardingDone = false;
          });
        } else {
          setState(() {
            isOnboardingDone = true;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isOnboardingDone ? const TablePage() : const OnboardingPage(),
      theme: ThemeData(fontFamily: "Pretendard"),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
      ],
    );
  }
}
