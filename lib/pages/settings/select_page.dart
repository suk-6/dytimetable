import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get/route_manager.dart';

import 'package:dytimetable/utils/pref.dart';
import 'package:dytimetable/utils/put.dart';

import 'package:dytimetable/widgets/circular_indicator_widget.dart';
import 'package:dytimetable/widgets/dropdown_widget.dart';

import 'package:dytimetable/firebase/firebase.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SelectPageState createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  late String selectedGrade = '';
  late String selectedClass = '';
  late String password = '';
  bool isLoading = false;
  bool isAvailable = false;

  Future<void> dialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('비밀번호 입력', textAlign: TextAlign.center),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
              ]);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.compare_arrows),
              onPressed: () {
                setState(() {
                  password = '';
                });

                dialog().then((value) {
                  checkPassword(password).then((value) {
                    if (value) {
                      Get.toNamed('/select-teacher');
                    } else {
                      ScaffoldMessenger.of(context).showMaterialBanner(
                        MaterialBanner(
                          content: const Text('비밀번호가 틀렸습니다.'),
                          actions: [
                            TextButton(
                                child: const Text('확인'),
                                onPressed: () {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentMaterialBanner();
                                }),
                          ],
                        ),
                      );
                    }
                  });
                });
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 25, right: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '학생 설정하기',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyDropdownBox(
                      width: 150,
                      hint: '학년 선택',
                      value: selectedGrade == '' ? null : selectedGrade,
                      onChanged: (String? value) {
                        setState(() {
                          selectedGrade = value!;
                          isAvailable =
                              selectedGrade != '' && selectedClass != '';
                        });
                      },
                      items: List.generate(3, (index) => index + 1)
                          .map((int value) {
                        return (
                          value: value.toString(),
                          child: '$value학년',
                        );
                      }),
                    ),
                    const SizedBox(width: 20),
                    MyDropdownBox(
                      width: 150,
                      hint: '반 선택',
                      value: selectedClass == '' ? null : selectedClass,
                      onChanged: (String? value) {
                        setState(() {
                          selectedClass = value!;
                          isAvailable =
                              selectedGrade != '' && selectedClass != '';
                        });
                      },
                      items: List.generate(10, (index) => index + 1)
                          .map((int value) {
                        return (
                          value: value.toString(),
                          child: '$value반',
                        );
                      }),
                    ),
                  ],
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: isLoading
                        ? const MyCircularProgressIndicator()
                        : isAvailable
                            ? ElevatedButton(
                                onPressed: () {
                                  if (selectedGrade != '' &&
                                      selectedClass != '') {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    FirebaseAnalytics.instance.logSelectContent(
                                      contentType: 'select_classroom',
                                      itemId: '$selectedGrade-$selectedClass',
                                    );
                                    subscribeToTopic(
                                            '$selectedGrade-$selectedClass')
                                        .then((value) {
                                      setMode('student')
                                          .then((value) => setState(() {
                                                isLoading = false;
                                              }))
                                          .then(
                                              (value) => Get.offAllNamed('/'));
                                    });
                                  }
                                },
                                style: ButtonStyle(
                                  minimumSize: WidgetStateProperty.all(
                                    const Size(double.infinity, 50),
                                  ),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  backgroundColor: WidgetStateProperty.all(
                                      Theme.of(context).colorScheme.secondary),
                                ),
                                child: const Text(
                                  '설정하기 ⚙',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              )
                            : Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  '학년과 반을 선택해주세요!',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
