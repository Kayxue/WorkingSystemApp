import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:working_system_app/Types/Gigs.dart';
import 'package:working_system_app/Types/PublicGigsReturn.dart';

class Findworks extends StatefulWidget {
  const Findworks({super.key});

  @override
  State<Findworks> createState() => _FindworksState();
}

class _FindworksState extends State<Findworks> {
  String searchQuery = "";
  late final _pagingController = PagingController<int, Gigs>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) async {
      final result = await fetchWorks(page: pageKey);
      return result;
    },
  );

  Future<List<Gigs>> fetchWorks({int page = 1}) async {
    final response = await http.get(
      Uri.parse(
        "http://0.0.0.0:3000/gig/public?page=$page${searchQuery.isNotEmpty ? "&search=$searchQuery" : ""}",
      ),
      headers: {"platform": "mobile"},
    );
    if (!mounted) return [];
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch works. Please try again.")),
      );
      return [];
    }
    final respond = jsonDecode(response.body) as Map<String, dynamic>;
    final parsed = Publicgigsreturn.fromJson(respond);
    return parsed.gigs;
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(top: 16, right: 16, left: 16, bottom: 8),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hint: Text("Search works", style: TextStyle(color: Colors.grey)),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          PagingListener(
            controller: _pagingController,
            builder: (context, state, fetchNextPage) => Expanded(
              child: RefreshIndicator(
                onRefresh: () => Future.sync(() => _pagingController.refresh()),
                child: PagedListView<int, Gigs>(
                  state: state,
                  fetchNextPage: fetchNextPage,
                  builderDelegate: PagedChildBuilderDelegate(
                    itemBuilder: (context, item, index) => Card(
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        splashColor: Colors.grey.withAlpha(30),
                        onTap: () {
                          //TODO: Show gig details
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Tapped on Work Title ${item.title}",
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          title: Text(item.title),
                          trailing: Text("\$${item.hourlyRate}"),
                          subtitle: Text("${item.city} ${item.district}"),
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
    );
  }
}
