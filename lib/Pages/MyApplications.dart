import 'package:flutter/material.dart';
import 'package:working_system_app/Others/Constant.dart';
import 'package:working_system_app/Pages/MyApplication/ApplicationList.dart';

class MyApplications extends StatefulWidget {
  final String sessionKey;

  const MyApplications({super.key, required this.sessionKey});

  @override
  State<MyApplications> createState() => _MyApplicationStates();
}

class _MyApplicationStates extends State<MyApplications>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text("My Applications"),
        bottom: TabBar(
          tabs: [
            const Tab(text: '未回覆'),
            const Tab(text: '審核中'),
            const Tab(text: '已接受'),
            const Tab(text: '未通過'),
          ],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ApplicationList(
            currentPageStatus: ApplicationStatus.pendingWorkerConfirmation,
            sessionKey: widget.sessionKey,
            moveToPage: moveToPage,
          ),
          ApplicationList(
            currentPageStatus: ApplicationStatus.pendingEmployerReview,
            sessionKey: widget.sessionKey,
            moveToPage: moveToPage,
          ),
          ApplicationList(
            currentPageStatus: ApplicationStatus.workerConfirmed,
            sessionKey: widget.sessionKey,
            moveToPage: moveToPage,
          ),
          ApplicationList(
            currentPageStatus: ApplicationStatus.inActive,
            sessionKey: widget.sessionKey,
            moveToPage: moveToPage,
          ),
        ],
      ),
    );
  }
}
