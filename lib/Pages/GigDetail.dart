import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Types/JSONObject/GigDetails.dart';
import 'package:working_system_app/Widget/GigDetail/GigInformation.dart';
import 'package:working_system_app/Widget/Others/LoadingIndicator.dart';

class GigDetail extends StatefulWidget {
  final String gigId;
  final String title;
  final String sessionKey;
  final Function clearSessionKey;

  const GigDetail({
    super.key,
    required this.gigId,
    required this.title,
    required this.sessionKey,
    required this.clearSessionKey,
  });

  @override
  State<GigDetail> createState() => _GigDetailState();
}

class _GigDetailState extends State<GigDetail> {
  GigDetails? gigdetail;
  bool isLoading = true;

  Future<GigDetails?> fetchGigDetail(String gigId) async {
    final response = await Utils.client.get(
      "/gig/public/$gigId",
      headers: .rawMap({"platform": "mobile", "cookie": widget.sessionKey}),
    );
    if (!mounted) return null;
    if (response.statusCode != 200) {
      //TODO: Handle error
    }
    final respond = jsonDecode(response.body) as Map<String, dynamic>;
    var parsed = GigDetails.fromJson(respond);
    parsed.hasConflict ??= false;
    parsed.hasPendingConflict ??= false;
    log('hasConflict: ${parsed.hasConflict}');
    log('hasPendingConflict: ${parsed.hasPendingConflict}');
    return parsed;
  }

  Future<void> sendApplication() async {
    final response = await Utils.client.post(
      "/application/apply/${widget.gigId}",
      headers: .rawMap({"platform": "mobile", "cookie": widget.sessionKey}),
    );
    if (!mounted) return;
    bool succeed = true;
    switch (response.statusCode) {
      case 404:
        succeed = false;
        await showStatusDialog(
          title: "Gig Not Exist",
          description:
              "Seems that this gig is not exist, or has expired, or has been deactivated",
        );
      case 400:
        succeed = false;
        await showStatusDialog(
          title: "Already Applied",
          description: "You have already applied for this gig.",
        );
      case 500:
        succeed = false;
        await showStatusDialog(
          title: "Unknown Error",
          description: "Unknown error, please report to developer.",
        );
      case 401:
        succeed = false;
        widget.clearSessionKey();
        await showStatusDialog(
          title: "Please login first",
          description: "Your session has expired, please login first.",
        );
    }
    if (!succeed) return;
    await showStatusDialog(
      title: "Succeed",
      description: "Application has been sent",
    );
    return;
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
          ? LoadingIndicator()
          : Padding(
              padding: const .only(left: 16, right: 16),
              child: Column(
                children: [
                  GigInformation(gigdetail: gigdetail!),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: .infinity,
                    child: FilledButton(
                      onPressed:
                          widget.sessionKey.isEmpty ||
                              gigdetail!.hasConflict == true ||
                              gigdetail!.applicationStatus ==
                                  'pending_employer_review' ||
                              gigdetail!.applicationStatus ==
                                  'pending_worker_confirmation'
                          ? null
                          : () async {
                              await sendApplication();
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                            },
                      child: Text(
                        widget.sessionKey.isEmpty
                            ? "Please login to apply to this gig"
                            : gigdetail!.applicationStatus ==
                                      'pending_employer_review' ||
                                  gigdetail!.applicationStatus ==
                                      'pending_worker_confirmation' ||
                                  gigdetail!.applicationStatus ==
                                      'worker_confirmed'
                            ? "You have already applied to this job"
                            : gigdetail!.hasConflict == true
                            ? "There is a confirm job conflict with this job"
                            : "Apply",
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
