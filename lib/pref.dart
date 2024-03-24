import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences? _prefs;

Future<void> initSharedPreferences() async {
  _prefs = await SharedPreferences.getInstance();
}

Future<void> setClassroom(String classroom) async {
  await _prefs!.setString('classroom', classroom);
}

Future<String?> getClassroom() async {
  return _prefs!.getString('classroom');
}
