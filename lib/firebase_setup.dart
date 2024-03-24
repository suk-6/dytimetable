import "package:flutter/foundation.dart";
import "package:firebase_core/firebase_core.dart";
import "package:firebase_messaging/firebase_messaging.dart";

import "package:dytimetable/firebase_options.dart";

Future<void> setupFlutterNotifications() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: false,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  getToken();
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
  await unsubscribeAllTopic()
      .then((_) => FirebaseMessaging.instance.subscribeToTopic(topic));
  debugPrint("subscribeToTopic : $topic");

  return;
}

Future<void> unsubscribeAllTopic() async {
  var grade = List.generate(3, (index) => index + 1);
  var classes = List.generate(10, (index) => index + 1);

  for (var g in grade) {
    for (var c in classes) {
      await FirebaseMessaging.instance.unsubscribeFromTopic("$g-$c");
    }
  }

  return;
}
