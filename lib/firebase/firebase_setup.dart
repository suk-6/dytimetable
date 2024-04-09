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

  FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
    _messageHandler(message, "foreground");
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
    _messageHandler(message, "background");
  });
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    _messageHandler(message, "terminated");
  });

  getToken();
}

Future<void> _onBackgroundMessage(RemoteMessage? message) async {}

Future<void> _messageHandler(
    RemoteMessage? message, String receivedType) async {
  if (message != null) {
    if (message.notification != null) {
      debugPrint(message.notification!.title);
      debugPrint(message.notification!.body);
      debugPrint(message.data["click_action"]);
      debugPrint(receivedType);
    }
  }
}

Future<void> getToken() async {
  String? token;

  // if (defaultTargetPlatform == TargetPlatform.iOS ||
  //     defaultTargetPlatform == TargetPlatform.macOS) {
  //   token = await FirebaseMessaging.instance.getAPNSToken();
  // } else {
  //   token = await FirebaseMessaging.instance.getToken();
  // }

  token = await FirebaseMessaging.instance.getToken();

  debugPrint("fcmToken : $token");
}

Future<void> subscribeToTopic(String topic) async {
  String? classroom = await getClassroom();
  String? isSubscribedAll = await getISA('isSubscribedAll');

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
