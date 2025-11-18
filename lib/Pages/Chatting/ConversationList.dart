import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:rhttp/rhttp.dart';
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
  final StreamController<dynamic> _streamController = StreamController<dynamic>.broadcast();

  late final _pagingController = PagingController<int, ConversationChat>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) async {
      final result = await fetchConversations(page: pageKey);
      return result;
    },
  );

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  @override
  void dispose() {
    client?.close();
    super.dispose();
  }

  Future<String> getToken() async {
    var response = await Utils.client.get(
      "/chat/ws-token",
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
    );
    if (!mounted) return '';
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get WebSocket token')),
      );
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['token'] as String;
  }

  void addEventListeners(String token) {
    // Pipe all messages from the WebSocket into the broadcast stream controller
    client!.listen(
      (message) {
        _streamController.add(message);
      },
      onDone: () {
        if (mounted) {
          setState(() {
            status = 'Disconnected';
            client = null;
          });
        }
        _streamController.close();
      },
      onError: (error) {
        _streamController.addError(error);
      },
    );

    // Listen to the broadcast stream for internal logic (heartbeat and list updates)
    _streamController.stream.listen((message) {
      final body = jsonDecode(message) as Map<String, dynamic>;
      if (body['type'] == 'heartbeat_request') {
        client!.add("{\"type\":\"heartbeat\"}");
      } else if (body['type'] == 'private_message') {
        final conversationId = body['conversationId'];
        final newLastMessage = body['content'];
        final newLastMessageAt = DateTime.parse(body['createdAt']);

        if (_pagingController.items != null) {
          final index = _pagingController.items!
              .indexWhere((c) => c.conversationId == conversationId);
          if (index != -1) {
            setState(() {
              final conversation = _pagingController.items![index];
              conversation.lastMessage = newLastMessage;
              conversation.lastMessageAt = newLastMessageAt;
              // Move the updated conversation to the top
              _pagingController.items!.removeAt(index);
              _pagingController.items!.insert(0, conversation);
            });
          }
        }
      }
    });
  }

  void _connectToWebSocket() async {
    if (client != null) {
      return;
    }

    final token = await getToken();
    if (token.isEmpty) return;

    client = await WebSocket.connect(
      "wss://${Constant.backendUrl.substring(8)}/chat/ws",
    ).then((client) {
      client.add("{\"type\":\"auth\", \"token\":\"$token\"}");
      if (mounted) {
        setState(() {
          status = 'Connected';
        });
      }
      return client;
    });

    addEventListeners(token);
  }

  Future<List<ConversationChat>> fetchConversations({int page = 0}) async {
    final response = await Utils.client.get(
      "/chat/conversations?page=$page",
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
    );
    if (!mounted) return [];
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch conversations. Please try again."),
        ),
      );
      return [];
    }
    debugPrint(response.body);
    final respond = jsonDecode(response.body) as Map<String, dynamic>;
    final parsed = ConversationResponse.fromJson(respond);
    return parsed.conversations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conversations')),
      body: Padding(
        padding: EdgeInsets.only(top: 16, right: 16, left: 16, bottom: 8),
        child: PagingListener(
          controller: _pagingController,
          builder: (context, state, fetchNextPage) => RefreshIndicator(
            onRefresh: () => Future.sync(() => _pagingController.refresh()),
            child: PagedListView<int, ConversationChat>(
              state: state,
              fetchNextPage: fetchNextPage,
              builderDelegate: PagedChildBuilderDelegate(
                itemBuilder: (context, item, index) => InkWell(
                    splashColor: Colors.grey.withAlpha(30),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 34,
                        backgroundImage: item.opponent.profilePhoto?.url != null
                            ? NetworkImage(item.opponent.profilePhoto!.url)
                            : AssetImage('assets/anonymous-profile-photo.png') as ImageProvider,
                      ),
                      title: Text(
                        item.opponent.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: item.lastMessageAt.isAfter(item.lastReadAtByWorker ?? DateTime.fromMillisecondsSinceEpoch(0))
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
                                color: item.lastMessageAt.isAfter(item.lastReadAtByWorker ?? DateTime.fromMillisecondsSinceEpoch(0))
                                    ? Colors.black
                                    : Colors.grey,
                                fontWeight: item.lastMessageAt.isAfter(item.lastReadAtByWorker ?? DateTime.fromMillisecondsSinceEpoch(0))
                                    ? FontWeight.normal
                                    : FontWeight.w200,
                              ),
                            ),
                            
                          ),
                          Text(
                            '•${DateFormat('yyyy/MM/dd HH:mm').format(item.lastMessageAt.toLocal())}',
                            style: TextStyle(
                              fontSize: 14,
                              color: item.lastMessageAt.isAfter(item.lastReadAtByWorker ?? DateTime.fromMillisecondsSinceEpoch(0))
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
                      _pagingController.refresh();
                    },
                  ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
