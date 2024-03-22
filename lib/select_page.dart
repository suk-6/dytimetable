import 'package:flutter/material.dart';
import 'firebase_setup.dart';

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SelectPageState createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  late String selectedGrade = '';
  late String selectedClass = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('시간표 알림 설정하기'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  hint: const Text('학년 선택'),
                  value: selectedGrade == '' ? null : selectedGrade,
                  onChanged: (String? value) {
                    setState(() {
                      selectedGrade = value!;
                    });
                  },
                  items:
                      List.generate(3, (index) => index + 1).map((int value) {
                    return DropdownMenuItem<String>(
                      value: value.toString(),
                      child: Text('$value학년'),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 20),
                DropdownButton<String>(
                  hint: const Text('반 선택'),
                  value: selectedClass == '' ? null : selectedClass,
                  onChanged: (String? value) {
                    setState(() {
                      selectedClass = value!;
                    });
                  },
                  items:
                      List.generate(10, (index) => index + 1).map((int value) {
                    return DropdownMenuItem<String>(
                      value: value.toString(),
                      child: Text('$value반'),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedGrade != '' && selectedClass != '') {
                  subscribeToTopic('$selectedGrade-$selectedClass');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('설정이 완료되었습니다.'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('학년과 반을 선택해주세요.'),
                    ),
                  );
                }
              },
              child: const Text('설정하기'),
            ),
          ],
        ),
      ),
    );
  }
}
