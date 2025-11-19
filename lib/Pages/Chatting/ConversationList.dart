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
  String? _activeConversationId;

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

    client =
        await WebSocket.connect(
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

    final index = conversations.indexWhere(
      (c) => c.conversationId == conversationId,
    );

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

  // --- Delete Conversation Logic ---

  void _showConversationContextMenu(
    BuildContext context,
    ConversationChat conversation,
  ) async {
    setState(() {
      _activeConversationId = conversation.conversationId;
    });

    await showModalBottomSheet(
      context: context,
      barrierColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.1,
          child: SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  minTileHeight: MediaQuery.of(context).size.height * 0.1,
                  leading: Icon(Icons.delete),
                  title: Text('Delete'),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeleteConversation(context, conversation);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    // After the bottom sheet is closed, reset the active conversation ID
    setState(() {
      _activeConversationId = null;
    });
  }

  Future<void> _confirmDeleteConversation(
    BuildContext context,
    ConversationChat conversation,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete Conversation'),
          content: Text(
            'Are you sure you want to delete this conversation? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteConversation(conversation.conversationId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteConversation(String conversationId) async {
    final response = await Utils.client.delete(
      "/chat/conversations/$conversationId",
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        conversations.removeWhere((c) => c.conversationId == conversationId);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Conversation deleted')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete conversation')));
    }
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

            return GestureDetector(
              onLongPress: () {
                _showConversationContextMenu(context, item);
              },
              child: InkWell(
                child: ListTile(
                  tileColor: _activeConversationId == item.conversationId
                      ? Colors.grey[300]
                      : null,
                  leading: CircleAvatar(
                    radius: 34,
                    backgroundImage: item.opponent.profilePhoto?.url != null
                        ? NetworkImage(item.opponent.profilePhoto!.url)
                        : const AssetImage('assets/anonymous-profile-photo.png')
                              as ImageProvider,
                  ),
                  title: Text(
                    item.opponent.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          item.lastMessageAt.isAfter(
                            item.lastReadAtByWorker ??
                                DateTime.fromMillisecondsSinceEpoch(0),
                          )
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
                            color:
                                item.lastMessageAt.isAfter(
                                  item.lastReadAtByWorker ??
                                      DateTime.fromMillisecondsSinceEpoch(0),
                                )
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ),
                      Text(
                        '•${DateFormat('yyyy/MM/dd HH:mm').format(item.lastMessageAt.toLocal())}',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              item.lastMessageAt.isAfter(
                                item.lastReadAtByWorker ??
                                    DateTime.fromMillisecondsSinceEpoch(0),
                              )
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
