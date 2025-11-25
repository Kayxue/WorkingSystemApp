import 'package:flutter/material.dart';
import 'package:working_system_app/Pages/Reviews/given_review.dart';
import 'package:working_system_app/Pages/Reviews/pending_review.dart';

class Reviews extends StatefulWidget {
  final String sessionKey;

  const Reviews({super.key, required this.sessionKey});

  @override
  State<Reviews> createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void moveToPage(int index) {
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gig Reviews"),
        bottom: TabBar(
          tabs: [
            Tab(text: "Unreviewed"),
            Tab(text: "Reviewed"),
          ],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PendingReview(sessionKey: widget.sessionKey, moveToPage: moveToPage),
          GivenReview(sessionKey: widget.sessionKey),
        ],
      ),
    );
  }
}
