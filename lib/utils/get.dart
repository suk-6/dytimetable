import 'dart:convert';
import 'package:dytimetable/utils/pref.dart';
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

  if (classroom == null || classroom == '교사') {
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
        if (data[i][j] == null) {
          timetableData[j + 1][i + 1] = '';
          continue;
        }

        data[i][j]["teacher"] = data[i][j]["teacher"].replaceAll('*', '');

        if (data[i][j]["teacher"].length > 3) {
          data[i][j]["teacher"] = data[i][j]["teacher"].substring(0, 2) + '...';
        }

        if (await getMode() == 'teacher' && classroom == '교사') {
          timetableData[j + 1][i + 1] =
              '${data[i][j]["subject"]}\n${data[i][j]["grade"]}-${data[i][j]["classroom"]}';
        } else {
          timetableData[j + 1][i + 1] =
              '${data[i][j]["subject"]}\n${data[i][j]["teacher"]}';
        }
      }
    }

    if (await getMode() == 'teacher') {
      timetableData[0][0] = '교사용';
    } else if (await getMode() == 'student') {
      timetableData[0][0] = "${data[0][0]["grade"]}-${data[0][0]["class"]}";
    }

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

Future<List<List<dynamic>>> getNoticeData() async {
  final urlClassroom = (await getClassroom())?.replaceFirst('-', '/');
  final response = await http
      .get(Uri.parse('https://timetable.dyhs.kr/getnotice/$urlClassroom'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    List<List<dynamic>> noticeData =
        List.generate(data.length, (index) => ['', '', '', '']);

    for (int i = 0; i < data.length; i++) {
      noticeData[i][0] = data[i][0];
      noticeData[i][1] = data[i][1];
      noticeData[i][2] = data[i][2];
      noticeData[i][3] = data[i][3];
    }

    noticeData.sort((a, b) => b[0].compareTo(a[0]));
    return noticeData;
  } else {
    throw Exception('Failed to load notice data');
  }
}

Future<List<String>> getTeachers() async {
  final response =
      await http.get(Uri.parse('https://timetable.dyhs.kr/getTeachers'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List<String> teachers = List.generate(data.length, (index) => '');

    for (int i = 0; i < data.length; i++) {
      teachers[i] = data[i];
    }

    return teachers;
  } else {
    throw Exception('Failed to load teachers data');
  }
}
