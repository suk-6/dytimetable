import "package:flutter/foundation.dart";
import "package:firebase_core/firebase_core.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import 'package:dytimetable/utils/pref.dart';

import "package:dytimetable/firebase/firebase_options.dart";

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

  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

  getToken();
}

Future<void> _onBackgroundMessage(RemoteMessage? message) async {}

Future<void> getToken() async {
  String? token;

  token = await FirebaseMessaging.instance.getToken();

  debugPrint("fcmToken : $token");
}

Future<void> subscribeToTopic(String topic) async {
  String? isSubscribedAll = await getISA('isSubscribedAll');

  String? mode = await getMode();

  if (mode == 'student') {
    String? classroom = await getClassroom();

    if (classroom != null) {
      await FirebaseMessaging.instance
          .unsubscribeFromTopic(classroom)
          .then((value) {
        debugPrint("unsubscribeFromTopic : $classroom");
      });
    }
  } else if (mode == 'teacher') {
    String? teacherNo = await getTeacherNo();

    if (teacherNo != null) {
      await FirebaseMessaging.instance
          .unsubscribeFromTopic(teacherNo)
          .then((value) {
        debugPrint("unsubscribeFromTopic : $teacherNo");
      });
    }
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
