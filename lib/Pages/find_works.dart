import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:convert';

import 'package:working_system_app/Others/utils.dart';
import 'package:working_system_app/Pages/gig_detail.dart';
import 'package:working_system_app/Types/JSONObject/gigs.dart';
import 'package:working_system_app/Types/JSONObject/public_gigs_return.dart';
import 'package:working_system_app/Widget/FindWorks/filter_bar.dart';

class FindWorks extends StatefulWidget {
  final Map<String, List<String>>? cityDistrictMap;
  final String sessionKey;
  final Function() clearSessionKey;

  const FindWorks({
    super.key,
    required this.cityDistrictMap,
    required this.sessionKey,
    required this.clearSessionKey,
  });

  @override
  State<FindWorks> createState() => _FindWorksState();
}

class _FindWorksState extends State<FindWorks> {
  String searchQuery = "";
  String selectedCity = "";
  String selectedDistrict = "";
  final TextEditingController districtController = TextEditingController();
  final textSearchObservable = PublishSubject<String>();

  late final _pagingController = PagingController<int, Gigs>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) async {
      final result = await fetchWorks(page: pageKey);
      return result;
    },
  );

  Future<List<Gigs>> fetchWorks({int page = 1}) async {
    final response = await Utils.client.get(
      "/gig/public?page=$page${searchQuery.isNotEmpty ? "&searchQuery=$searchQuery" : ""}${selectedCity.isNotEmpty ? "&city=$selectedCity" : ""}${selectedDistrict.isNotEmpty ? "&district=$selectedDistrict" : ""}",
      headers: .rawMap({"platform": "mobile"}),
    );
    if (!mounted) return [];
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch works. Please try again.")),
      );
      return [];
    }
    final respond = jsonDecode(response.body) as Map<String, dynamic>;
    final parsed = PublicGigsReturn.fromJson(respond);
    return parsed.gigs;
  }

  void setCity(String city) {
    setState(() {
      selectedCity = city;
      selectedDistrict = "";
      districtController.value = TextEditingValue(text: "無指定區");
      _pagingController.refresh();
    });
  }

  void setDistrict(String district) {
    setState(() {
      selectedDistrict = district;
      _pagingController.refresh();
    });
  }

  @override
  void initState() {
    super.initState();
    textSearchObservable
        .debounceTime(Duration(milliseconds: 500))
        .distinct()
        .listen((query) {
          setState(() {
            searchQuery = query;
            _pagingController.refresh();
          });
        });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    textSearchObservable.close();
    districtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .only(top: 16, right: 16, left: 16),
      child: Column(
        children: [
          FilterBar(
            cityDistrictMap: widget.cityDistrictMap,
            setCity: setCity,
            setDistrict: setDistrict,
            selectedCity: selectedCity,
            selectedDistrict: selectedDistrict,
            districtController: districtController,
            textSearchObservable: textSearchObservable,
          ),
          const SizedBox(height: 16),
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
                      clipBehavior: .hardEdge,
                      child: InkWell(
                        splashColor: Colors.grey.withAlpha(30),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => GigDetail(
                                gigId: item.gigId,
                                title: item.title,
                                sessionKey: widget.sessionKey,
                                clearSessionKey: widget.clearSessionKey,
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
