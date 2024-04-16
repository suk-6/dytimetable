import 'dart:convert';

import 'package:dytimetable/utils/pref.dart';
import 'package:http/http.dart' as http;

Future<String> sendNotice(
    String title, String content, String password, String classroom) async {
  final response = await http.post(
    Uri.parse('https://timetable.dyhs.kr/sendnotice'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'sender': await getClassroom(),
      'title': title,
      'content': content,
      'password': password,
      'receiver': classroom,
    }),
  );

  return response.body;
}

Future<bool> checkPassword(String password) async {
  final response = await http.post(
    Uri.parse('https://timetable.dyhs.kr/checkpassword'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'password': password,
    }),
  );

  return response.body == 'true';
}
