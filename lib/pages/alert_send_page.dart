import 'package:dytimetable/utils/put.dart';
import 'package:dytimetable/utils/tools.dart';
import 'package:flutter/material.dart';

class AlertSendPage extends StatefulWidget {
  const AlertSendPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AlertSendPageState createState() => _AlertSendPageState();
}

class _AlertSendPageState extends State<AlertSendPage> {
  final List<Widget> children = <Widget>[
    const Padding(
      padding: EdgeInsets.all(10.0),
      child: Text('전체'),
    ),
    const Padding(
      padding: EdgeInsets.all(10.0),
      child: Text('학급'),
    ),
  ];

  final List<bool> isSelected = <bool>[false, false];

  String selectedClassroom = '1-1';

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const SizedBox(height: 16.0),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '제목',
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              maxLines: 5,
              controller: contentController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '내용',
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '비밀번호',
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ToggleButtons(
                isSelected: isSelected,
                children: children,
                onPressed: (int index) {
                  setState(() {
                    for (int buttonIndex = 0;
                        buttonIndex < isSelected.length;
                        buttonIndex++) {
                      if (buttonIndex == index) {
                        isSelected[buttonIndex] = true;
                      } else {
                        isSelected[buttonIndex] = false;
                      }
                    }
                  });
                },
              ),
              isSelected[1]
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: DropdownButton(
                          value: selectedClassroom,
                          items: generateClassroomList(false).map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedClassroom = value.toString();
                            });
                          }),
                    )
                  : const SizedBox(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              child: const Text('전송'),
              onPressed: () {
                sendNotice(
                  titleController.text,
                  contentController.text,
                  passwordController.text,
                  isSelected[1] ? selectedClassroom : 'all',
                ).then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(value),
                  ));
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
