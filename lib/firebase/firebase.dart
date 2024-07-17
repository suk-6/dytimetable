import "package:flutter/foundation.dart";

import "package:get/route_manager.dart";
import "package:url_launcher/url_launcher.dart";

import 'package:dytimetable/utils/pref.dart';

import "package:flutter_local_notifications/flutter_local_notifications.dart";

import "package:firebase_core/firebase_core.dart";
import "package:dytimetable/firebase/firebase_options.dart";
import "package:firebase_messaging/firebase_messaging.dart";

Future<void> setupFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: false,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  await FlutterLocalNotificationsPlugin()
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
          'high_importance_channel', 'High Importance Notifications',
          importance: Importance.max));

  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

  getToken();
}

Future<void> _onBackgroundMessage(RemoteMessage message) async {
  // if (message.data['type'] == 'period') {
  //   flutterLocalNotificationsPlugin.show(
  //       0,
  //       message.data["title"],
  //       message.data["body"],
  //       const NotificationDetails(
  //         android: AndroidNotificationDetails(
  //           'high_importance_channel',
  //           'High Importance Notifications',
  //           importance: Importance.max,
  //           priority: Priority.high,
  //           showWhen: false,
  //         ),
  //       ),
  //       payload: jsonEncode(message.data));
  //   Future<void>.delayed(const Duration(seconds: 3), () {
  //     flutterLocalNotificationsPlugin.cancel(0);
  //   });
  // }
}

void handleMessage(RemoteMessage message) {
  if (message.data['click_action'] == 'notice') {
    Get.toNamed('/alert');
  } else if (message.data['click_action'] == 'url') {
    launchUrl(Uri.parse(message.data['data']!));
  } else if (message.data['click_action'] == 'meal') {
    Get.toNamed('/meal');
  }
}

Future<void> getToken() async {
  String? token;

  token = await FirebaseMessaging.instance.getToken();

  debugPrint("fcmToken : $token");
}

Future<void> subscribeToTopic(String topic) async {
  String? isSubscribedAll = await getISA('isSubscribedAll');

  String? classroom = await getClassroom();

  if (classroom != null) {
    await FirebaseMessaging.instance
        .unsubscribeFromTopic(classroom)
        .then((value) {
      debugPrint("unsubscribeFromTopic : $classroom");
    });
  }

  if (isSubscribedAll == null) {
    await FirebaseMessaging.instance
        .subscribeToTopic("all")
        .then((value) async {
      await setISA('isSubscribedAll', '1');
      debugPrint("subscribeToTopic : all");
    });
  }

  await FirebaseMessaging.instance.subscribeToTopic(topic).then((value) async {
    await setClassroom(topic);
    debugPrint("subscribeToTopic : $topic");
  });

  return;
}
