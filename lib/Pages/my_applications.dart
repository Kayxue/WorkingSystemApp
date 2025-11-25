import 'package:flutter/material.dart';
import 'package:working_system_app/Others/constant.dart';
import 'package:working_system_app/Others/utils.dart';
import 'package:working_system_app/Pages/MyApplication/application_list.dart';

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

  Future<bool> _showConfirmationDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('確認'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _handleApplicationAction(
    String applicationId,
    String action,
    bool hasConflict,
  ) async {
    final title = action == 'accept' ? '確認接受' : '確認婉拒';
    final content = action == 'accept' ? '您確定要接受此工作邀請嗎？' : '您確定要婉拒此工作邀請嗎？';

    final confirmed = await _showConfirmationDialog(title, content);
    if (!confirmed || !mounted) return;

    if (action == 'accept') {
      if (hasConflict) {
        final confirmed = await _showConfirmationDialog(
          '確認接受',
          '此工作與其他已確認的工作有衝突，您確定要接受此工作邀請嗎？',
        );
        if (!confirmed || !mounted) return;
      }
    }

    try {
      final response = await Utils.client.put(
        '/application/$applicationId/confirm',
        headers: .rawMap({'cookie': widget.sessionKey}),
        body: .json({'action': action}),
      );

      Utils.logger.d(
        'Application action response: ${response.statusCode} ${response.body}',
      );

      if (response.statusCode == 200) {
        if (action == 'accept') {
          moveToPage(2);
        } else {
          moveToPage(3);
        }
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _withdrawApplication(String applicationId) async {
    final confirmed = await _showConfirmationDialog('確認取消申請', '您確定要取消這個工作申請嗎？');
    if (!confirmed || !mounted) return;

    try {
      final response = await Utils.client.post(
        '/application/cancel/$applicationId',
        headers: .rawMap({'cookie': widget.sessionKey}),
      );

      if (response.statusCode == 200) {
        moveToPage(3);
      } else {
        Utils.logger.e(
          'Failed to withdraw application: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      // Handle error
    }
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
            currentPage: ApplicationPage.pendingWorkerConfirmation,
            sessionKey: widget.sessionKey,
            moveToPage: moveToPage,
            handleActions: _handleApplicationAction,
            handleWithdraw: _withdrawApplication,
          ),
          ApplicationList(
            currentPage: ApplicationPage.pendingEmployerReview,
            sessionKey: widget.sessionKey,
            moveToPage: moveToPage,
            handleActions: _handleApplicationAction,
            handleWithdraw: _withdrawApplication,
          ),
          ApplicationList(
            currentPage: ApplicationPage.workerConfirmed,
            sessionKey: widget.sessionKey,
            moveToPage: moveToPage,
            handleActions: _handleApplicationAction,
            handleWithdraw: _withdrawApplication,
          ),
          ApplicationList(
            currentPage: ApplicationPage.inActive,
            sessionKey: widget.sessionKey,
            moveToPage: moveToPage,
            handleActions: _handleApplicationAction,
            handleWithdraw: _withdrawApplication,
          ),
        ],
      ),
    );
  }
}
