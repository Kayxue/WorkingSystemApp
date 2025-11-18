import 'dart:convert' show jsonDecode;

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Pages/Reviews/GivingReview.dart';
import 'package:working_system_app/Types/JSONObject/WorkerReview.dart';
import 'package:working_system_app/Types/JSONObject/WorkerReviewReturn.dart';

class PendingReview extends StatefulWidget {
  final String sessionKey;
  final Function(int) moveToPage;

  const PendingReview({
    super.key,
    required this.sessionKey,
    required this.moveToPage,
  });

  @override
  State<PendingReview> createState() => _PendingReviewState();
}

class _PendingReviewState extends State<PendingReview> {
  late final _pagingController = PagingController<int, WorkerReview>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) async {
      final result = await fetchPendingReview(page: pageKey);
      return result;
    },
  );

  Future<List<WorkerReview>> fetchPendingReview({int page = 1}) async {
    final response = await Utils.client.get(
      "/rating/list/worker?page=$page",
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
    final parsed = WorkerReviewReturn.fromJson(respond);
    return parsed.ratableGigs;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .only(top: 16, right: 16, left: 16, bottom: 8),
      child: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) => RefreshIndicator(
          onRefresh: () => Future.sync(() => _pagingController.refresh()),
          child: PagedListView<int, WorkerReview>(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (context, item, index) => Card(
                clipBehavior: .hardEdge,
                child: InkWell(
                  splashColor: Colors.grey.withAlpha(30),
                  onTap: () async {
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (context) => GivingReview(
                          unreviewedGig: item,
                          sessionKey: widget.sessionKey,
                        ),
                      ),
                    );
                    if (result == true) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Review submitted successfully."),
                        ),
                      );
                      widget.moveToPage(1);
                    }
                  },
                  child: ListTile(
                    title: Text(item.title),
                    subtitle: Text(item.employer.name),
                    trailing: const Text(
                      "Unreviewed",
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
