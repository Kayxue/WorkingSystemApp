import 'dart:convert' show jsonDecode;

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:rhttp/rhttp.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Types/WorkerReview.dart';
import 'package:working_system_app/Types/WorkerReviewReturn.dart';

class PendingReview extends StatefulWidget {
  final String sessionKey;

  const PendingReview({super.key, required this.sessionKey});

  @override
  State<PendingReview> createState() => _PendingReviewState();
}

class _PendingReviewState extends State<PendingReview> {
  late final _pagingController = PagingController<int, WorkerReview>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) async {
      final result = await fetchWorks(page: pageKey);
      return result;
    },
  );

  Future<List<WorkerReview>> fetchWorks({int page = 1}) async {
    final response = await Utils.client.get(
      "/rating/list/worker?page=$page",
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
    final parsed = WorkerReviewReturn.fromJson(respond);
    return parsed.ratableGigs;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16, right: 16, left: 16, bottom: 8),
      child: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) => RefreshIndicator(
          onRefresh: () => Future.sync(() => _pagingController.refresh()),
          child: PagedListView<int, WorkerReview>(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (context, item, index) => Card(
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  splashColor: Colors.grey.withAlpha(30),
                  onTap: () {
                    //TDOO: Add rating page
                  },
                  child: ListTile(
                    title: Text(item.title),
                    subtitle: Text(item.employer.name),
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
