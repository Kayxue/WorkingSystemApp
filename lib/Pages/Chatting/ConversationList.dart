import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:rhttp/rhttp.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:working_system_app/Others/Constant.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Pages/Chatting/ChattingRoom.dart';
import 'package:working_system_app/Types/JSONObject/Conversation/ConversationChat.dart';
import 'package:working_system_app/Types/JSONObject/Conversation/ConversationResponse.dart';

class ConversationList extends StatefulWidget {
  final String sessionKey;

  const ConversationList({super.key, required this.sessionKey});

  @override
  State<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  WebSocket? client;
  String status = 'Disconnected';
  StreamSubscription? _wsSubscription;

  final StreamController<dynamic> _streamController =
      StreamController<dynamic>.broadcast();

  

  final ScrollController _scrollController = ScrollController();

  List<ConversationChat> conversations = [];
  int currentPage = 0;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
    _loadMore(); // load page 0

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    client?.close();
    _streamController.close();
    _scrollController.dispose();
    super.dispose();
  }

  /// -------------------------
  /// Load Conversation Pages
  /// -------------------------
  Future<void> _loadMore() async {
    if (isLoading || !hasMore) return;
    if (!mounted) return;
    setState(() => isLoading = true);

    final newList = await fetchConversations(page: currentPage);
    if (newList.isEmpty) {
      setState(() {
        hasMore = false;
        isLoading = false;
      });
      return;
    }
    setState(() {
      conversations.addAll(newList);
      currentPage += 1;
      isLoading = false;
    });
  }

  Future<List<ConversationChat>> fetchConversations({int page = 0}) async {
    final response = await Utils.client.get(
      "/chat/conversations?pages=$page",
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
    );
    if (response.statusCode != 200) return [];

    final jsonBody = jsonDecode(response.body);
    final parsed = ConversationResponse.fromJson(jsonBody);
    return parsed.conversations;
  }

  /// -------------------------
  /// WebSocket Setup
  /// -------------------------
  Future<String> getToken() async {
    final response = await Utils.client.get(
      "/chat/ws-token",
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
    );

    if (response.statusCode != 200) return '';

    final body = jsonDecode(response.body);
    return body["token"];
  }

  void _connectToWebSocket() async {
    if (client != null) return;

    final token = await getToken();
    if (token.isEmpty) return;

    client = await WebSocket.connect(
      "wss://${Constant.backendUrl.substring(8)}/chat/ws",
    ).then((ws) {
      ws.add(jsonEncode({"type": "auth", "token": token}));
      if (!mounted) return ws;
      setState(() => status = "Connected");
      return ws;
    });

    client!.listen(
      (data) {
        if (!_streamController.isClosed) {
          _streamController.add(data);
        }
      },
      onDone: () {
        if (!mounted) return;
        setState(() {
          status = 'Disconnected';
          client = null;
        });
      },
      onError: (e) => debugPrint("WebSocket error: $e"),
    );

    _wsSubscription = _streamController.stream.listen((message) {
      if (!mounted) return;
      _handleWSMessage(message);
    });
  }

  /// -------------------------
  /// Handle WebSocket Messages
  /// -------------------------
  void _handleWSMessage(dynamic raw) {
    final body = jsonDecode(raw);

    if (body["type"] == "heartbeat_request") {
      client!.add("{\"type\":\"heartbeat\"}");
    }

    if (body["type"] == "private_message") {
      _updateConversation(body);
    }
  }

  /// -------------------------
  /// Update One Conversation
  /// -------------------------
  void _updateConversation(Map<String, dynamic> data) {
    final conversationId = data["conversationId"];
    final newLastMessage = data["content"];
    final newLastMessageAt = DateTime.parse(data["createdAt"]);

    final index =
        conversations.indexWhere((c) => c.conversationId == conversationId);

    if (index == -1) return;
    if (!mounted) return;
    setState(() {
      final convo = conversations[index];
      convo.lastMessage = newLastMessage;
      convo.lastMessageAt = newLastMessageAt;

      // Move to top
      conversations.removeAt(index);
      conversations.insert(0, convo);
    });
  }

  /// -------------------------
  /// UI
  /// -------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Conversations")),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            // conversations.clear();
            currentPage = 0;
            hasMore = true;
          });
          await _loadMore();
        },
        child: ListView.builder(
          controller: _scrollController,
          itemCount: conversations.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == conversations.length) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final item = conversations[index];

            return InkWell(
              child: ListTile(
                leading: CircleAvatar(
                  radius: 34,
                  backgroundImage: item.opponent.profilePhoto?.url != null
                      ? NetworkImage(item.opponent.profilePhoto!.url)
                      : const AssetImage(
                              'assets/anonymous-profile-photo.png')
                          as ImageProvider,
                ),
                title: Text(
                  item.opponent.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: item.lastMessageAt.isAfter(
                            item.lastReadAtByWorker ??
                                DateTime.fromMillisecondsSinceEpoch(0))
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.lastMessage ?? 'No messages yet',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: item.lastMessageAt.isAfter(
                                  item.lastReadAtByWorker ??
                                      DateTime.fromMillisecondsSinceEpoch(0))
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                    Text(
                      '•${DateFormat('yyyy/MM/dd HH:mm').format(item.lastMessageAt.toLocal())}',
                      style: TextStyle(
                          fontSize: 14,
                          color: item.lastMessageAt.isAfter(
                                  item.lastReadAtByWorker ??
                                      DateTime.fromMillisecondsSinceEpoch(0))
                              ? Colors.black
                              : Colors.grey),
                    )
                  ],
                ),
              ),
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChattingRoom(
                      sessionKey: widget.sessionKey,
                      conversationId: item.conversationId,
                      opponentName: item.opponent.name,
                      opponentId: item.opponent.id,
                      client: client,
                      stream: _streamController.stream,
                    ),
                  ),
                );

                // After return, refresh latest conversations
                setState(() {
                  conversations.clear();
                  currentPage = 0;
                  hasMore = true;
                });
                _loadMore();
              },
            );
          },
        ),
      ),
    );
  }
}
