import 'dart:convert';
import 'package:dytimetable/pref.dart';
import 'package:http/http.dart' as http;

Future<List<List<String>>> getTimeTableData(String? classroom) async {
  List<List<String>> timetableData = [
    ['', '월', '화', '수', '목', '금'],
    ['1교시', '', '', '', '', ''],
    ['2교시', '', '', '', '', ''],
    ['3교시', '', '', '', '', ''],
    ['4교시', '', '', '', '', ''],
    ['5교시', '', '', '', '', ''],
    ['6교시', '', '', '', '', ''],
    ['7교시', '', '', '', '', ''],
  ];
  late String? urlClassroom;

  if (classroom == null) {
    urlClassroom = (await getClassroom())?.replaceFirst('-', '/');
  } else {
    urlClassroom = classroom.replaceFirst('-', '/');
  }

  final response = await http
      .get(Uri.parse('https://timetable.dyhs.kr/getTable/$urlClassroom'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 7; j++) {
        timetableData[j + 1][i + 1] =
            '${data[i][j]["subject"]}\n${data[i][j]["teacher"]}';
      }
    }

    timetableData[0][0] = "${data[0][0]["grade"]}-${data[0][0]["class"]}";

    return timetableData;
  } else {
    throw Exception('Failed to load timetable data');
  }
}

Future<List<List<dynamic>>> getMealData() async {
  final response =
      await http.get(Uri.parse('https://timetable.dyhs.kr/getmeal'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    List<List<dynamic>> mealData =
        List.generate(data.length, (index) => ['', '', '']);

    for (int i = 0; i < data.length; i++) {
      mealData[i][0] = data[i][0];
      mealData[i][1] = data[i][1];
      mealData[i][2] = data[i][0] ? data[i][2] : '급식이 없습니다.';
    }

    return mealData;
  } else {
    throw Exception('Failed to load meal data');
  }
}
