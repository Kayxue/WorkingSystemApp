import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Types/JSONObject/GigDetails.dart';
import 'package:working_system_app/Widget/GigDetail/GigInformation.dart';
import 'package:working_system_app/Widget/Others/LoadingIndicator.dart';
import 'package:working_system_app/Pages/Chatting/ChattingRoom.dart';
import 'package:working_system_app/Types/JSONObject/Message/GigMessage.dart';

class ApplicationGigDetails extends StatefulWidget {
  final String gigId;
  final String title;
  final String applicationId;
  final String sessionKey;
  final String status;
  final bool acceptEnabled;

  const ApplicationGigDetails({
    super.key,
    required this.gigId,
    required this.title,
    required this.applicationId,
    required this.sessionKey,
    required this.status,
    required this.acceptEnabled,
  });

  @override
  State<ApplicationGigDetails> createState() => _ApplicationGigDetailsState();
}

class _ApplicationGigDetailsState extends State<ApplicationGigDetails> {
  GigDetails? gigdetail;
  bool isLoading = true;

  Future<GigDetails?> fetchGigDetail(String gigId) async {
    final response = await Utils.client.get(
      "/gig/worker/$gigId",
      headers: .rawMap({"cookie": widget.sessionKey}),
    );
    if (!mounted) return null;
    if (response.statusCode != 200) {
      //TODO: Handle error
    }
    final respond = jsonDecode(response.body) as Map<String, dynamic>;
    final parsed = GigDetails.fromJson(respond);
    return parsed;
  }

  Future<bool> _showConfirmationDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('確認'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _handleApplicationAction(
    String applicationId,
    String action,
  ) async {
    final title = action == 'accept' ? '確認接受' : '確認婉拒';
    final content = action == 'accept' ? '您確定要接受此工作邀請嗎？' : '您確定要婉拒此工作邀請嗎？';

    final confirmed = await _showConfirmationDialog(title, content);
    if (!confirmed || !mounted) return;

    try {
      final response = await Utils.client.put(
        '/application/$applicationId/confirm',
        headers: .rawMap({'cookie': widget.sessionKey}),
        body: .json({'action': action}),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(action == 'accept' ? '工作已接受' : '工作已婉拒')),
        );
        Navigator.of(context).pop(action == 'accept');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('操作失敗，請稍後再試')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('發生錯誤，請稍後再試')));
    }
  }

  Future<void> _withdrawApplication(String applicationId) async {
    final confirmed = await _showConfirmationDialog('確認取消申請', '您確定要取消這個工作申請嗎？');
    if (!confirmed || !mounted) return;

    try {
      final response = await Utils.client.post(
        '/application/cancel/$applicationId',
        headers: .rawMap({'cookie': widget.sessionKey}),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('申請已取消')));
        Navigator.of(context).pop(false);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('操作失敗，請稍後再試')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('發生錯誤，請稍後再試')));
    }
  }

  Future<void> _startPrivateChat() async {
    final response = await Utils.client.post(
      "/chat/gig/${widget.gigId}",
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
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
        SnackBar(
          content: Text('Failed to start private chat: ${response.body}'),
        ),
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

  Widget _buildActionButtons() {
    if (widget.status == 'pending_employer_review') {
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const .only(right: 8),
              child: ElevatedButton(
                onPressed: () => _startPrivateChat(),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50),
                ),
                child: const Text('聊天', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: () => _withdrawApplication(widget.applicationId),
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
              child: const Text(
                '取消申請',
                style: TextStyle(fontWeight: .bold, fontSize: 16),
              ),
            ),
          ),
        ],
      );
    } else if (widget.status == 'pending_worker_confirmation') {
      return Row(
        mainAxisAlignment: .spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => _startPrivateChat(),
            style: ElevatedButton.styleFrom(
              fixedSize: Size(MediaQuery.of(context).size.width * 0.9, 50),
            ),
            child: const Text('聊天', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () =>
                _handleApplicationAction(widget.applicationId, 'reject'),
            style: ElevatedButton.styleFrom(
              fixedSize: Size(MediaQuery.of(context).size.width * 0.4, 50),
              side: const BorderSide(color: Colors.red, width: 1),
            ),
            child: const Text(
              '拒絕',
              style: TextStyle(
                color: Colors.red,
                fontWeight: .bold,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: widget.acceptEnabled
                ? () => _handleApplicationAction(widget.applicationId, 'accept')
                : null,
            style: ElevatedButton.styleFrom(
              fixedSize: Size(MediaQuery.of(context).size.width * 0.4, 50),
              side: BorderSide(
                color: widget.acceptEnabled ? Colors.green : Colors.grey,
                width: 1,
              ),
            ),
            child: Text(
              '接受',
              style: TextStyle(
                color: widget.acceptEnabled ? Colors.green : Colors.grey,
                fontWeight: .bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const .only(right: 8),
              child: ElevatedButton(
                onPressed: () => _startPrivateChat(),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50),
                  // fixedSize: Size(MediaQuery.of(context).size.width * 0.4, 50),
                ),
                child: const Text('聊天', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: () => _withdrawApplication(widget.applicationId),
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50),
                // fixedSize: Size(MediaQuery.of(context).size.width * 0.9, 50),
              ),
              child: Text(switch (widget.status) {
                'employer_rejected' => '被拒絕',
                'worker_confirmed' => '已接受',
                'worker_declined' => '已拒絕',
                'worker_cancelled' => '已取消',
                'system_cancelled' => '已取消',
                _ => '取消申請',
              }, style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: isLoading
          ? LoadingIndicator()
          : Padding(
              padding: const .only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: [
                  GigInformation(
                    gigdetail: gigdetail!,
                    applicationGig: true,
                    sessionKey: widget.sessionKey,
                    applicationId: widget.applicationId,
                  ),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }
}
