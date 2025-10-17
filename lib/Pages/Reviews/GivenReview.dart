import 'dart:convert' show jsonDecode;

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:rhttp/rhttp.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Types/WorkerGivenReviewReturn.dart';
import 'package:working_system_app/Types/WorkerRatings.dart';
import 'package:working_system_app/Types/WorkerReview.dart';
import 'package:working_system_app/Types/WorkerReviewReturn.dart';

class GivenReview extends StatefulWidget {
  final String sessionKey;

  const GivenReview({super.key, required this.sessionKey});

  @override
  State<GivenReview> createState() => _GivenReviewState();
}

class _GivenReviewState extends State<GivenReview> {
  late final _pagingController = PagingController<int, WorkerRatings>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) async {
      final result = await fetchWorks(page: pageKey);
      return result;
    },
  );

  Future<List<WorkerRatings>> fetchWorks({int page = 1}) async {
    final response = await Utils.client.get(
      "/rating/my-ratings/worker?page=$page",
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
    final parsed = WorkerGivenReviewReturn.fromJson(respond);
    return parsed.myRatings;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16, right: 16, left: 16, bottom: 8),
      child: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) => RefreshIndicator(
          onRefresh: () => Future.sync(() => _pagingController.refresh()),
          child: PagedListView<int, WorkerRatings>(
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
                    title: Text(item.gig.title),
                    subtitle: Text(item.comment),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.ratingValue.toStringAsFixed(1),
                          style: TextStyle(fontSize: 24, color: Colors.amber),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.star, color: Colors.amber),
                      ],
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
