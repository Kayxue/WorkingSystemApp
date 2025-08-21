import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:rhttp/rhttp.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:convert';

import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Pages/GigDetail.dart';
import 'package:working_system_app/Types/Gigs.dart';
import 'package:working_system_app/Types/PublicGigsReturn.dart';
import 'package:working_system_app/Widget/FilterBar.dart';

class Findworks extends StatefulWidget {
  final Map<String, List<String>>? cityDistrictMap;

  const Findworks({super.key, required this.cityDistrictMap});

  @override
  State<Findworks> createState() => _FindworksState();
}

class _FindworksState extends State<Findworks> {
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
      headers: HttpHeaders.rawMap({"platform": "mobile"}),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16, right: 16, left: 16, bottom: 8),
      child: Column(
        children: [
          Filterbar(
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
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        splashColor: Colors.grey.withAlpha(30),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Gigdetail(
                                gigId: item.gigId,
                                title: item.title,
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
