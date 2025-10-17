import 'package:flutter/material.dart';
import 'package:working_system_app/Pages/Reviews/GivenReview.dart';
import 'package:working_system_app/Pages/Reviews/PendingReview.dart';

class Reviews extends StatelessWidget {
  final String sessionKey;

  const Reviews({super.key, required this.sessionKey});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Gig Reviews"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Already Given"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PendingReview(sessionKey: sessionKey),
            GivenReview(sessionKey: sessionKey),
          ],
        ),
      ),
    );
  }
}
