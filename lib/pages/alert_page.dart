import 'package:dytimetable/pages/alert_view_page.dart';
import 'package:dytimetable/utils/get.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AlertPageState createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  late Future noticeData = getNoticeData();

  @override
  void initState() {
    noticeData = getNoticeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: FutureBuilder(
            future: noticeData,
            builder: (context, snapshot) {
              FirebaseAnalytics.instance.logEvent(name: "alert_page");
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('오류가 발생했습니다.'));
              } else {
                return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        noticeData = getNoticeData();
                      });
                    },
                    child: ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                              onTap: () {
                                FirebaseAnalytics.instance
                                    .logEvent(name: "click_alert_in_list");
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return AlertViewPage(snapshot.data[index]);
                                }));
                              },
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                color: Colors.grey[200],
                                borderOnForeground: true,
                                shadowColor: Colors.grey[400],
                                child: ListTile(
                                  leading: const Icon(Icons.notifications),
                                  title: Text(snapshot.data[index][1]),
                                  subtitle: Text(snapshot.data[index][2]),
                                  trailing: Text(snapshot.data[index][3]),
                                ),
                              ));
                        }));
              }
            }));
  }
}
