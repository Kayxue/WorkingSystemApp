import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Types/GigDetails.dart';
import 'package:animated_read_more_text/animated_read_more_text.dart';

class Gigdetail extends StatefulWidget {
  final String gigId;
  final String title;
  final String sessionKey;

  const Gigdetail({
    super.key,
    required this.gigId,
    required this.title,
    required this.sessionKey,
  });

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

  Future<bool> sendApplication() async {
    final response = await Utils.client.post(
      "/application/apply/${widget.gigId}",
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
    );
    if (!mounted) return false;
    bool succeed = true;
    switch (response.statusCode) {
      case 404:
        succeed = false;
        await showStatusDialog(
          succeed,
          title: "Gig Not Exist",
          description:
              "Seems that this gig is not exist, or has expired, or has been deactivated",
        );
      case 400:
        succeed = false;
        await showStatusDialog(
          succeed,
          title: "Already Applied",
          description: "You have already applied for this gig.",
        );
      case 500:
        succeed = false;
        await showStatusDialog(
          succeed,
          title: "Unknown Error",
          description: "Unknown error, please report to developer.",
        );
      case 401:
        //TODO: Handle 401
        print("Error 401");
    }
    if (!succeed) return false;
    await showStatusDialog(
      succeed,
      title: "Succeed",
      description: "Application has been sent",
    );
    return true;
  }

  Future<void> showStatusDialog(
    bool succeed, {
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
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              "Details",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Card(
                            child: ListTile(
                              title: Text(
                                "Description",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: AnimatedReadMoreText(
                                gigdetail!.description,
                                maxLines: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.sessionKey.isEmpty
                          ? null
                          : () async {
                              if (await sendApplication()) {
                                if (!mounted) return;
                                Navigator.of(context).pop();
                              }
                            },
                      child: Text(
                        widget.sessionKey.isEmpty
                            ? "Please login to apply this gig"
                            : "Apply",
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
