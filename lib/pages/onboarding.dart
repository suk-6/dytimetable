import 'package:flutter/material.dart';

import 'package:get/route_manager.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logTutorialBegin();
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            FirebaseAnalytics.instance.logTutorialComplete();
            Get.offAllNamed('/select');
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
            onPageChanged: ((index, reason) {}),
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
