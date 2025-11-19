import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Types/JSONObject/GigDetails.dart';
import 'package:working_system_app/Widget/GigDetail/GigInformation.dart';
import 'package:working_system_app/Pages/Chatting/ChattingRoom.dart';
import 'package:working_system_app/Types/JSONObject/Message/GigMessage.dart';

class GigDetailsNoButton extends StatefulWidget {
  final String gigId;
  final String title;
  final String sessionKey;

  const GigDetailsNoButton({
    super.key,
    required this.gigId,
    required this.title,
    required this.sessionKey,
  });

  @override
  State<GigDetailsNoButton> createState() => _GigDetailsNoButtonState();
}

class _GigDetailsNoButtonState extends State<GigDetailsNoButton> {
  GigDetails? gigdetail;
  bool isLoading = true;

  Future<GigDetails?> fetchGigDetail(String gigId) async {
    final response = await Utils.client.get(
      "/gig/worker/$gigId",
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
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

  Future<void> _startPrivateChat() async {
    final response = await Utils.client.post(
      "/gig/${widget.gigId}",
      headers: HttpHeaders.rawMap({"platform": "mobile", "cookie": widget.sessionKey}),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final gigMessage = GigMessage.fromJson(jsonDecode(response.body));

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChattingRoom(
            sessionKey: widget.sessionKey,
            conversationId: gigMessage.message.conversationId,
            opponentName: gigMessage.employerName,
            opponentId: gigMessage.gig.employerId,
            client: null,
            stream: null,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start private chat: ${response.body}')),
      );
    }
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
              padding: const .only(left: 16, right: 16),
              child: Column(
                children: [
                  GigInformation(gigdetail: gigdetail!),
                  SizedBox(height: 16),
                  Row(
                    children:[
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: FilledButton(
                            onPressed: widget.sessionKey.isEmpty
                                ? null
                                : () => _startPrivateChat(),
                            child: const Text("Chat"),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
