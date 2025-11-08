import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:rhttp/rhttp.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Types/JSONObject/Conflict/ConfirmedGig.dart';
import 'package:working_system_app/Types/JSONObject/Conflict/ConflictReturn.dart';
import 'package:working_system_app/Widget/ViewConflict/GigCard.dart';

class ConfirmedList extends StatefulWidget {
  final String sessionKey;
  final String conflictType;
  final String applicationId;

  const ConfirmedList({
    super.key,
    required this.sessionKey,
    required this.conflictType,
    required this.applicationId,
  });

  @override
  State<ConfirmedList> createState() => _ConfirmedListState();
}

class _ConfirmedListState extends State<ConfirmedList> {
  late final _pagingController = PagingController<int, ConfirmedGig>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) async {
      final result = await fetchPendingConflicts(page: pageKey);
      return result;
    },
  );

  Future<List<ConfirmedGig>> fetchPendingConflicts({int page = 1}) async {
    final response = await Utils.client.get(
      "/application/${widget.applicationId}/conflicts?type=${widget.conflictType}&page=$page",
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
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
    return parsed.confirmedGigConflicts;
  }

  @override
  Widget build(BuildContext context) {
    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) => RefreshIndicator(
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: PagedListView<int, ConfirmedGig>(
          state: state,
          fetchNextPage: fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, item, index) => GigCard(gig: item, sessionKey: widget.sessionKey),
          ),
        ),
      ),
    );
  }
}