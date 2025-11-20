import 'dart:async';
import 'dart:convert';

import 'package:rhttp/rhttp.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:working_system_app/mixins/ChatWebSocketMixin.dart';
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

class _ConversationListState extends State<ConversationList>
    with ChatWebSocketMixin {
  String status = 'Disconnected';
  String? _activeConversationId;

  final ScrollController _scrollController = ScrollController();

  List<ConversationChat> conversations = [];
  int currentPage = 0;
  bool isLoading = false;
  bool hasMore = true;

  @override
  String get sessionKey => widget.sessionKey;

  @override
  void initState() {
    super.initState();
    connectChatWebSocket();
    _loadMore(); // load page 0

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  @override
  void onWebSocketConnected() {
    // Update connection status when WebSocket is ready
    if (mounted) {
      setState(() => status = 'Connected');
    }
  }

  @override
  void dispose() {
    closeChatWebSocket();
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

  /// Override to handle chat messages for conversation list
  @override
  void onChatMessage(Map<String, dynamic> message) {
    if (message["type"] == "private_message") {
      _updateConversation(message);
    }
  }

  /// -------------------------
  /// Mark Conversation as Read
  /// -------------------------
  Future<void> markConversationAsRead(String conversationId) async {
    await Utils.client.post(
      "/chat/conversations/$conversationId/read",
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
    );

    // Update the local state to reflect the read status
    final index = conversations.indexWhere(
      (c) => c.conversationId == conversationId,
    );
    if (index != -1 && mounted) {
      setState(() {
        conversations[index].lastReadAtByWorker = DateTime.now();
      });
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
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMenuOption(
                    icon: Icons.mark_chat_read,
                    label: '標記已讀',
                    backgroundColor: Colors.blue[100]!,
                    iconColor: Colors.blue[700]!,
                    onTap: () {
                      Navigator.pop(context);
                      markConversationAsRead(conversation.conversationId);
                    },
                  ),
                  _buildMenuOption(
                    icon: Icons.delete_outline,
                    label: '刪除',
                    backgroundColor: Colors.red[100]!,
                    iconColor: Colors.red[700]!,
                    onTap: () {
                      Navigator.pop(context);
                      _confirmDeleteConversation(context, conversation);
                    },
                  ),
                ],
              ),
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

  Widget _buildMenuOption({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              SizedBox(height: 8),
              Text(label, style: TextStyle(color: Colors.black, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
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
                        client: chatWebSocket,
                        stream: chatStream,
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
