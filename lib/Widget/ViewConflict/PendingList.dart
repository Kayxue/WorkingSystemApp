import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Types/JSONObject/Conflict/ConflictReturn.dart';
import 'package:working_system_app/Types/JSONObject/Conflict/PendingApplication.dart';
import 'package:working_system_app/Widget/ViewConflict/PendingApplicationCard.dart';

class PendingList extends StatefulWidget {
  final String sessionKey;
  final String conflictType;
  final String applicationId;

  const PendingList({
    super.key,
    required this.sessionKey,
    required this.conflictType,
    required this.applicationId,
  });

  @override
  State<PendingList> createState() => _PendingListState();
}

class _PendingListState extends State<PendingList> {
  late final _pagingController = PagingController<int, PendingApplication>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) async {
      final result = await fetchPendingConflicts(page: pageKey);
      return result;
    },
  );

  Future<List<PendingApplication>> fetchPendingConflicts({int page = 1}) async {
    final response = await Utils.client.get(
      "/application/${widget.applicationId}/conflicts?type=${widget.conflictType}&page=$page",
      headers: .rawMap({"platform": "mobile", "cookie": widget.sessionKey}),
    );
    if (!mounted) return [];
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch works. Please try again.")),
      );
      return [];
    }
    final respond = jsonDecode(response.body) as Map<String, dynamic>;
    final parsed = ConflictReturn.fromJson(respond);
    return parsed.pendingApplicationConflicts;
  }

  Future<void> _rejectApplicationAction(String applicationId) async {
    final confirmed = await _showConfirmationDialog('確認拒絕', '您確定要拒絕此工作邀請嗎？');
    if (!confirmed || !mounted) return;

    try {
      final response = await Utils.client.put(
        '/application/$applicationId/confirm',
        headers: .rawMap({'cookie': widget.sessionKey}),
        body: .json({'action': 'reject'}),
      );

      if (response.statusCode == 200) {
        _pagingController.refresh();
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
        _pagingController.refresh();
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    }
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

  @override
  Widget build(BuildContext context) {
    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) => RefreshIndicator(
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: PagedListView<int, PendingApplication>(
          state: state,
          fetchNextPage: fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, item, index) => PendingApplicationCard(
              app: item,
              onReject: () => _rejectApplicationAction(item.applicationId),
              onWithdraw: () => _withdrawApplication(item.applicationId),
              sessionKey: widget.sessionKey,
            ),
          ),
        ),
      ),
    );
  }
}
