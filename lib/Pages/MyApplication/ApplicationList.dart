import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:working_system_app/Others/Constant.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Types/JSONObject/Application.dart';
import 'package:working_system_app/Types/JSONObject/UserApplication.dart';
import 'package:working_system_app/Widget/MyApplications/ApplicationCard.dart';

class ApplicationList extends StatefulWidget {
  final ApplicationStatus currentPageStatus;
  final String sessionKey;
  final Function(int) moveToPage;
  final Function(String, String, bool) handleActions;
  final Function(String) handleWithdraw;

  const ApplicationList({
    super.key,
    required this.currentPageStatus,
    required this.sessionKey,
    required this.moveToPage,
    required this.handleActions,
    required this.handleWithdraw,
  });

  @override
  State<ApplicationList> createState() => _ApplicationListState();
}

class _ApplicationListState extends State<ApplicationList> {
  late final _pagingController = PagingController<int, Application>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) async {
      final result = await fetchApplications(page: pageKey);
      return result;
    },
  );

  Future<List<Application>> fetchApplications({int page = 1}) async {
    final response = await Utils.client.get(
      "/application/my-applications?page=$page&status=${widget.currentPageStatus.statusStr}",
      headers: .rawMap({"platform": "mobile", "cookie": widget.sessionKey}),
    );
    if (!mounted) return [];
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch applications. Please try again."),
        ),
      );
      return [];
    }
    final respond = jsonDecode(response.body) as Map<String, dynamic>;
    final parsed = UserApplication.fromJson(respond);
    return parsed.applications;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .only(top: 16, right: 16, left: 16, bottom: 8),
      child: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) => RefreshIndicator(
          onRefresh: () => Future.sync(() => _pagingController.refresh()),
          child: PagedListView<int, Application>(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (context, item, index) => ApplicationCard(
                sessionKey: widget.sessionKey,
                application: item,
                moveToPage: widget.moveToPage,
                handleActions: widget.handleActions,
                handleWithdraw: widget.handleWithdraw,
                refreshPage: _pagingController.refresh,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
