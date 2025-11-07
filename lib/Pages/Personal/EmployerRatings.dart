import 'dart:convert';
import 'dart:typed_data';

import 'package:animated_read_more_text/animated_read_more_text.dart';
import 'package:apple_like_avatar_generator/apple_like_avatar_generator.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:rhttp/rhttp.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Types/JSONObject/GivenReviewReturn.dart';
import 'package:working_system_app/Types/JSONObject/Ratings.dart';
import 'package:working_system_app/Types/JSONObject/WorkerProfile.dart';

class EmployerRatings extends StatefulWidget {
  final WorkerProfile profile;
  final String sessionKey;

  const EmployerRatings({
    super.key,
    required this.profile,
    required this.sessionKey,
  });

  @override
  State<EmployerRatings> createState() => _EmployerRatingsState();
}

class _EmployerRatingsState extends State<EmployerRatings> {
  late final _pagingController = PagingController<int, Ratings>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) async {
      final result = await fetchWorks(page: pageKey);
      return result;
    },
  );

  Future<List<Ratings>> fetchWorks({int page = 1}) async {
    final response = await Utils.client.get(
      "/rating/received-ratings/worker?page=$page",
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
    final parsed = GivenReviewReturn.fromJson(respond);
    return parsed.ratings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipOval(
                    child: widget.profile.profilePhoto != null
                        ? Image.network(
                            widget.profile.profilePhoto!.url,
                            width: 70,
                            height: 70,
                          )
                        : FutureBuilder<Uint8List>(
                            future: AppleLikeAvatarGenerator.generateWithName(
                              "${widget.profile.firstName}${widget.profile.lastName}",
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors
                                      .transparent, // Transparent background
                                );
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  width: 70,
                                  height: 70,
                                );
                              } else {
                                return const Text('No data');
                              }
                            },
                          ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "${widget.profile.firstName} ${widget.profile.lastName}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.profile.ratingStats.averageRating
                              .toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 1),
                        Icon(Icons.star, color: Colors.amber, size: 20),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      "${widget.profile.ratingStats.totalRatings} reviews",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      DateTime.now()
                                  .difference(widget.profile.createdAt)
                                  .inDays >=
                              365
                          ? "${(DateTime.now().difference(widget.profile.createdAt).inDays / 365).floor()} years"
                          : DateTime.now()
                                    .difference(widget.profile.createdAt)
                                    .inDays >=
                                30
                          ? "${(DateTime.now().difference(widget.profile.createdAt).inDays / 30).floor()} months"
                          : "${DateTime.now().difference(widget.profile.createdAt).inDays} days",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "already joined",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "Reviews from Employers",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            PagingListener(
              controller: _pagingController,
              builder: (context, state, fetchNextPage) => Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      Future.sync(() => _pagingController.refresh()),
                  child: PagedListView<int, Ratings>(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    builderDelegate: PagedChildBuilderDelegate(
                      itemBuilder: (context, item, index) => Card(
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          splashColor: Colors.grey.withAlpha(30),
                          onTap: () {},
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text(item.employer.name),
                                subtitle: Text(
                                  "For gig: ${item.gig.title}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      item.ratingValue.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.amber,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 16,
                                ),
                                child: AnimatedReadMoreText(
                                  item.comment ?? "No comments provided.",
                                  maxLines: 2,
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    color: item.comment != null
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
