import 'package:flutter/material.dart';

ThemeData initThemeData({required Brightness brightness}) {
  if (brightness == Brightness.light) {
    return ThemeData(
      fontFamily: "Pretendard",
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF5798F8),
        secondary: Color(0xFFF8B757),
      ),
    );
  } else {
    return ThemeData(
      fontFamily: "Pretendard",
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF5798F8),
        secondary: Color(0xFFF8B757),
      ),
    );
  }
}
