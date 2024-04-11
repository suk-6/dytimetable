import 'package:flutter/material.dart';

class AlertViewPage extends StatelessWidget {
  final List<dynamic> data;
  const AlertViewPage(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data[1],
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 30.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                data[3],
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
              ),
              const Divider(),
              const SizedBox(height: 10.0),
              Text(
                data[2],
                style: const TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
        ));
  }
}
