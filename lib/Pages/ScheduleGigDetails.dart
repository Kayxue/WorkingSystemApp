import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Types/JSONObject/GigDetails.dart';
import 'package:working_system_app/Widget/GigInformation.dart';

class ScheduleGigDetails extends StatefulWidget {
  final String gigId;
  final String title;

  const ScheduleGigDetails({
    super.key,
    required this.gigId,
    required this.title,
  });

  @override
  State<ScheduleGigDetails> createState() => _ScheduleGigDetailsState();
}

class _ScheduleGigDetailsState extends State<ScheduleGigDetails> {
  GigDetails? gigdetail;
  bool isLoading = true;

  Future<GigDetails?> fetchGigDetail(String gigId) async {
    final response = await Utils.client.get(
      "/gig/public/$gigId",
      headers: const HttpHeaders.rawMap({"platform": "mobile"}),
    );
    if (!mounted) return null;
    if (response.statusCode != 200) {
      //TODO: Handle error
    }
    final respond = jsonDecode(response.body) as Map<String, dynamic>;
    final parsed = GigDetails.fromJson(respond);
    return parsed;
  }

  Future<void> showStatusDialog({
    required String title,
    required String description,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
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
      appBar: AppBar(title: Text(widget.title)),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text("Loading", style: TextStyle(fontSize: 12)),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                children: [
                  GigInformation(gigdetail: gigdetail!),
                  SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
