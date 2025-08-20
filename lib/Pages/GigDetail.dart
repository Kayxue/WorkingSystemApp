import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Types/GigDetails.dart';

class Gigdetail extends StatefulWidget {
  final String gigId;

  const Gigdetail({super.key, required this.gigId});

  @override
  State<Gigdetail> createState() => _GigdetailState();
}

class _GigdetailState extends State<Gigdetail> {
  Gigdetails? gigdetail;
  bool isLoading = true;

  Future<Gigdetails?> fetchGigDetail(String gigId) async {
    final response = await Utils.client.get(
      "/gig/public/$gigId",
      headers: const HttpHeaders.rawMap({"platform": "mobile"}),
    );
    if (!mounted) return null;
    if (response.statusCode != 200) {
      //TODO: Handle error
    }
    final respond = jsonDecode(response.body) as Map<String, dynamic>;
    final parsed = Gigdetails.fromJson(respond);
    return parsed;
  }

  @override
  void initState() {
    super.initState();
    fetchGigDetail(widget.gigId).then((value) {
      if (!mounted) return;
      setState(() {
        gigdetail = value;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLoading ? "Loading..." : gigdetail!.title)),
      body: Center(
        child: Text(
          isLoading
              ? "Loading gig details..."
              : (gigdetail!.description is Map
                    ? gigdetail!.description.toString()
                    : gigdetail!.description),
        ),
      ),
    );
  }
}
