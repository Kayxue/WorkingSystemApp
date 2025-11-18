import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:rhttp/rhttp.dart';
import 'package:flutter/material.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Types/JSONObject/Message/Message.dart';

class ChattingRoom extends StatefulWidget {
  final String sessionKey;
  final String conversationId;
  final String opponentName;
  final String opponentId;
  final WebSocket? client;
  final Stream<dynamic> stream;

  const ChattingRoom({
    super.key,
    required this.sessionKey,
    required this.conversationId,
    required this.opponentName,
    required this.opponentId,
    required this.client,
    required this.stream,
  });

  @override
  State<ChattingRoom> createState() => _ChattingRoomState();
}

class _ChattingRoomState extends State<ChattingRoom> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> messages = [];
  String? olderCursor; // ISO timestamp
  bool isLoadingOlder = false;
  bool hasMore = true;

  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    super.initState();

    _loadInitial();

    // detect reach top -> load older messages
    _scrollController.addListener(() {
      if (_scrollController.position.pixels <=
          _scrollController.position.minScrollExtent + 20) {
        _loadOlderMessages();
      }
    });

    // websocket new messages
    _streamSubscription = widget.stream.listen(_handleIncomingMessage);
  }

  /// ----------------------------------------
  /// Load initial newest messages
  /// ----------------------------------------
  Future<void> _loadInitial() async {
    final url =
        "/chat/conversations/${widget.conversationId}/messages";

    final response = await Utils.client.get(
      url,
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
    );

    if (response.statusCode != 200) return;

    final list = jsonDecode(response.body) as List;
    final msgs = list.map((e) => Message.fromJson(e)).toList();
    setState(() {
      messages = msgs.reversed.toList();
      if (msgs.length == 20) {
        olderCursor = msgs.first.createdAt.toString();
      }else {
        hasMore = false;
      }
    });

    await Future.delayed(Duration(milliseconds: 50));
  }

  /// ----------------------------------------
  /// Load older messages using ?before=timestamp
  /// ----------------------------------------
  Future<void> _loadOlderMessages() async {
    if (isLoadingOlder || !hasMore || olderCursor == null) return;

    setState(() => isLoadingOlder = true);

    final url =
        "/chat/conversations/${widget.conversationId}/messages?before=$olderCursor";

    final response = await Utils.client.get(
      url,
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
    );

    if (response.statusCode != 200) {
      print("Failed to load older messages");
      setState(() => isLoadingOlder = false);
      return;
    }

    final list = jsonDecode(response.body) as List;
    final older = list.map((e) => Message.fromJson(e)).toList().reversed.toList();
    if (older.length < 20) {
      setState(() {
        messages.insertAll(messages.length, older);
        hasMore = false;
        isLoadingOlder = false;
      });
      return;
    }

    setState(() {
      messages.insertAll(0, older);
      olderCursor = older.last.createdAt.toIso8601String();
      isLoadingOlder = false;
    });
  }

  /// ----------------------------------------
  /// Handle websocket incoming message
  /// ----------------------------------------
  void _handleIncomingMessage(dynamic data) {
    final body = jsonDecode(data);

    if (body["type"] == "private_message" &&
        body["conversationId"] == widget.conversationId) {
      final msg = Message.fromJson(body);

      setState(() {
        // insert at last
        messages.insert(0, msg);
      });

    }
  }

  /// ----------------------------------------
  /// Send message
  /// ----------------------------------------
  void _sendMessage() {
    if (_textController.text.trim().isEmpty || widget.client == null) return;

    final text = _textController.text.trim();

    widget.client!.add(jsonEncode({
      "type": "private_message",
      "recipientId": widget.opponentId,
      "text": text,
    }));

    // optimistic insert
    final optimistic = Message(
      messagesId: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: widget.conversationId,
      content: text,
      createdAt: DateTime.now(),
      senderWorkerId: null,
      senderEmployerId: null,
    );

    setState(() {
      messages.insert(0, optimistic);
    });

    _textController.clear();
  }

  /// ----------------------------------------
  /// Scroll helper
  /// ----------------------------------------
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }

  /// ----------------------------------------
  /// UI
  /// ----------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.opponentName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              itemCount: messages.length + (isLoadingOlder ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == messages.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final msg = messages[i];
                final isMe = msg.senderWorkerId != null;

                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg.content),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat("yyyy-MM-dd HH:mm").format(msg.createdAt.toLocal()),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Send a message...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
