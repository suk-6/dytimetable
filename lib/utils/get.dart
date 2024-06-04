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

  if (classroom == null) {
    urlClassroom = (await getClassroom())?.replaceFirst('-', '/');
  } else {
    urlClassroom = classroom.replaceFirst('-', '/');
  }

  final response = await http
      .get(Uri.parse('https://timetable.dyhs.kr/v2/timetable/$urlClassroom'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    for (int i = 1; i <= 5; i++) {
      final weekday = data[i.toString()];
      for (int j = 0; j < weekday.length; j++) {
        final period = weekday[j];
        if (period == null) {
          timetableData[j + 1][i] = '';
          continue;
        }

        period["teacher"] = period["teacher"].replaceAll('*', '');

        if (period["teacher"].length > 3) {
          period["teacher"] = period["teacher"].substring(0, 2) + '...';
        }

        if (await getMode() == 'teacher' &&
            urlClassroom.toString().lastIndexOf('teacher') == 0) {
          timetableData[j + 1][i] =
              '${period["subject"]}\n${period["grade"]}-${period["class"]}';
        } else {
          timetableData[j + 1][i] =
              '${period["subject"]}\n${period["teacher"]}${period["isChanged"] ? '@' : ''}';
        }
      }
    }

    if (await getMode() == 'teacher') {
      timetableData[0][0] = '교사용';
    } else if (await getMode() == 'student') {
      timetableData[0][0] = classroom ?? '학생용';
    }

    return timetableData;
  } else {
    throw Exception('Failed to load timetable data');
  }
}

Future<List<List<dynamic>>> getMealData() async {
  final response =
      await http.get(Uri.parse('https://timetable.dyhs.kr/v2/neis/meal'));

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
      .get(Uri.parse('https://timetable.dyhs.kr/v2/notice/$urlClassroom'));

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
  final response = await http
      .get(Uri.parse('https://timetable.dyhs.kr/v2/timetable/teachers'));

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
