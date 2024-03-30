import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:dytimetable/select_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SelectPage()),
                (route) => false);
          },
        )
      ]),
      body: Center(
        child: CarouselSlider(
          options: CarouselOptions(
            height: double.infinity,
            aspectRatio: 16 / 9,
            viewportFraction: 1,
            autoPlay: false,
            autoPlayInterval: const Duration(seconds: 4),
            onPageChanged: ((index, reason) {
              // 페이지가 슬라이드될 때의 기능 정의
            }),
          ),
          items: [
            'assets/images/onboarding-1.png',
            'assets/images/onboarding-2.png',
            'assets/images/onboarding-3.png',
          ].map((String item) {
            return Image.asset(item, fit: BoxFit.contain);
          }).toList(),
        ),
      ),
    ));
  }
}
