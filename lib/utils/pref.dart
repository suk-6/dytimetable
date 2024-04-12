import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences? _prefs;

Future<void> initSharedPreferences() async {
  _prefs = await SharedPreferences.getInstance();
}

Future<void> setMode(String mode) async {
  await _prefs!.setString('mode', mode);
}

Future<String?> getMode() async {
  return _prefs!.getString('mode');
}

String? getModeSync() {
  return _prefs!.getString('mode');
}

Future<void> setTeacherNo(String teacherNo) async {
  await _prefs!.setString('teacherNo', teacherNo);
}

Future<String?> getTeacherNo() async {
  return _prefs!.getString('teacherNo');
}

Future<void> setClassroom(String classroom) async {
  await _prefs!.setString('classroom', classroom);
}

Future<String?> getClassroom() async {
  return _prefs!.getString('classroom');
}

Future<void> setISA(String key, String value) async {
  await _prefs!.setString(key, value);
}

Future<String?> getISA(String key) async {
  return _prefs!.getString(key);
}
