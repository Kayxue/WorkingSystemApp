import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:working_system_app/Types/GigPagination.dart';
import 'package:working_system_app/Types/Gigs.dart';
import 'package:working_system_app/Types/PublicGigsReturn.dart';

class Findworks extends StatefulWidget {
  const Findworks({super.key});

  @override
  State<Findworks> createState() => _FindworksState();
}

class _FindworksState extends State<Findworks> {
  bool isFetching = true;
  late List<Gigs> gigs;
  late Gigpagination pagination;

  Future<void> fetchInitialWorks() async {
    final response = await http.get(
      Uri.parse("http://0.0.0.0:3000/gig/public?dateStart=2025-01-01"),
      headers: {"platform": "mobile"},
    );
    if (!mounted) return;
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch works. Please try again.")),
      );
      return;
    }
    final respond = jsonDecode(response.body) as Map<String, dynamic>;
    final parsed = Publicgigsreturn.fromJson(respond);
    // print(parsed.toJson());
    setState(() {
      gigs = parsed.gigs;
      pagination = parsed.pagination;
    });
    if (gigs.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("No works found.")));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchInitialWorks().then((_) {
      setState(() {
        isFetching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isFetching
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading", style: TextStyle(fontSize: 16)),
              ],
            ),
          )
        : Padding(
            padding: EdgeInsetsGeometry.only(top: 16, right: 16, left: 16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hint: Text(
                      "Search works",
                      style: TextStyle(color: Colors.grey),
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: fetchInitialWorks,
                    child: ListView.builder(
                      itemCount: gigs.length,
                      itemBuilder: (context, index) {
                        final work= gigs[index];
                        return Card(
                          child: ListTile(
                            title: Text(work.title),
                            subtitle: Text("${work.city} ${work.district}"),
                            trailing: Text(work.hourlyRate.toString()),
                            onTap: () {
                              // Handle tap
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Tapped on Work Title ${work.title}"),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
