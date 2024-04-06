import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dytimetable/pages/select_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            ListTile(
              title: const Text('학년 / 반 설정'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const SelectPage();
                }));
              },
            ),
            ListTile(
              title: const Text('개발자에게 문의하기'),
              onTap: () {
                try {
                  launchUrlString('mailto:me@suk.kr');
                } on Exception {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('메일 앱을 찾을 수 없습니다.'),
                  ));
                }
              },
            ),
            ListTile(
              title: const Text('덕영시간표 소개 바로가기'),
              onTap: () {
                launchUrl(Uri.parse('https://timetable.dyhs.kr'));
              },
            ),
            ListTile(
              title: const Text('덕영시간표 설치 링크 복사하기'),
              onTap: () {
                try {
                  Clipboard.setData(const ClipboardData(
                      text: 'https://timetable.dyhs.kr/install'));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('복사되었습니다.'),
                  ));
                } on Exception {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('실패했습니다.'),
                  ));
                }
              },
            ),
            ListTile(
              title: const Text('학교 홈페이지 바로가기'),
              onTap: () {
                launchUrl(Uri.parse('https://dukyoung-h.goeyi.kr'));
              },
            ),
            ListTile(
              title: const Text('개인정보처리방침 바로가기'),
              onTap: () {
                launchUrl(Uri.parse(
                    'https://dukyoung-h.goeyi.kr/dukyoung-h/iv/indvdlView/selectIndvdlView.do'));
              },
            ),
            ListTile(
              title: const Text('컴시간학생 바로가기'),
              onTap: () {
                launchUrl(Uri.parse('http://comci.net:4082/st'));
              },
            ),
          ],
        ));
  }
}
