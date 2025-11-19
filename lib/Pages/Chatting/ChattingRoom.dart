import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:rhttp/rhttp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:working_system_app/Others/Constant.dart';
import 'package:working_system_app/Pages/GigDetail.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Types/JSONObject/Message/Message.dart';

class ChattingRoom extends StatefulWidget {
  final String sessionKey;
  final String conversationId;
  final String opponentName;
  final String opponentId;
  final WebSocket? client;
  final Stream<dynamic>? stream;

  const ChattingRoom({
    super.key,
    required this.sessionKey,
    required this.conversationId,
    required this.opponentName,
    required this.opponentId,
    this.client,
    this.stream,
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
  Message? _replyingToMessage;
  String? _activeMessageId;
  String resetKey = "";

  // Local WebSocket and StreamController if we are not getting them from ConversationList
  WebSocket? _localClient;
  StreamController<dynamic>? _localStreamController;
  StreamSubscription? _streamSubscription;

  // Getter for the active WebSocket client
  WebSocket? get _activeClient => widget.client ?? _localClient;
  // Getter for the active Stream
  Stream<dynamic>? get _activeStream =>
      widget.stream ?? _localStreamController?.stream;

  @override
  void initState() {
    super.initState();

    // Initialize local WebSocket if not provided by widget
    if (widget.client == null) {
      _initializeLocalWebSocket();
    }

    _loadInitial();

    // detect reach top -> load older messages
    _scrollController.addListener(() {
      if (_scrollController.position.pixels <=
          _scrollController.position.minScrollExtent + 20) {
        _loadOlderMessages();
      }
    });

    // websocket new messages
    _streamSubscription = _activeStream?.listen(_handleIncomingMessage);

    markConversationAsRead();
  }

  Future<void> markConversationAsRead() async {
    await Utils.client.post(
      "/chat/conversations/${widget.conversationId}/read",
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
    );
  }

  // --- WebSocket Logic ---
  Future<String> _getToken() async {
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

  void _addEventListeners(String token) {
    _localClient!.listen(
      (message) {
        _localStreamController?.add(message);
      },
      onDone: () {
        if (mounted) {
          setState(() {
            _localClient = null; // Clear local client on disconnect
          });
        }
        _localStreamController?.close();
      },
      onError: (error) {
        _localStreamController?.addError(error);
      },
    );

    // Listen to the local broadcast stream for internal logic (heartbeat and list updates)
    _localStreamController?.stream.listen((message) {
      final body = jsonDecode(message) as Map<String, dynamic>;
      if (body['type'] == 'heartbeat_request') {
        _localClient!.add("{\"type\":\"heartbeat\"}");
      }
      // Other global events could be handled here if needed
    });
  }

  void _initializeLocalWebSocket() async {
    if (_localClient != null) {
      return;
    }

    final token = await _getToken();
    if (token.isEmpty) return;

    _localStreamController = StreamController<dynamic>.broadcast();

    _localClient =
        await WebSocket.connect(
          "wss://${Constant.backendUrl.substring(8)}/chat/ws",
        ).then((client) {
          client.add("{\"type\":\"auth\", \"token\":\"$token\"}");
          if (mounted) {
            setState(() {
              // Update status if needed, but this room is isolated
            });
          }
          return client;
        });

    _addEventListeners(token);
  }

  /// ----------------------------------------
  /// Load initial newest messages
  /// ----------------------------------------
  Future<void> _loadInitial() async {
    final url =
        "/chat/conversations/${widget.conversationId}/messages?limit=20";

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
        olderCursor = msgs.first.createdAt.toIso8601String();
      } else {
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
    print("Loading older messages before $olderCursor");

    final url =
        "/chat/conversations/${widget.conversationId}/messages?limit=20&before=$olderCursor";

    print(url);
    final response = await Utils.client.get(
      url,
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
    );

    if (response.statusCode != 200) {
      print("Failed to load older messages");
      print(response.body);
      setState(() => isLoadingOlder = false);
      return;
    }

    final list = jsonDecode(response.body) as List;
    final older = list
        .map((e) => Message.fromJson(e))
        .toList()
        .reversed
        .toList();
    if (older.length < 20) {
      setState(() {
        messages.addAll(older);

        hasMore = false;
        isLoadingOlder = false;
      });
      return;
    }

    setState(() {
      messages.addAll(older);
      olderCursor = older.last.createdAt.toIso8601String();
      isLoadingOlder = false;
    });
  }

  /// ----------------------------------------
  /// Handle websocket incoming message
  /// ----------------------------------------
  void _handleIncomingMessage(dynamic data) {
    final body = jsonDecode(data);
    final type = body['type'];

    if (type == "private_message" &&
        body["conversationId"] == widget.conversationId) {
      final msg = Message.fromJson(body);
      setState(() {
        messages.insert(0, msg);
      });
    } else if (type == "message_retracted") {
      final messageId = body['messageId'];
      final index = messages.indexWhere((m) => m.messagesId == messageId);
      if (index != -1) {
        setState(() {
          messages[index] = Message(
            messagesId: messages[index].messagesId,
            conversationId: messages[index].conversationId,
            content: '[訊息已撤回]',
            createdAt: messages[index].createdAt,
            senderWorkerId: messages[index].senderWorkerId,
            senderEmployerId: messages[index].senderEmployerId,
          );
        });
      }
    }
  }

  /// ----------------------------------------
  /// Send message
  /// ----------------------------------------
  void _sendMessage() {
    if (_textController.text.trim().isEmpty || _activeClient == null)
      return; // Use _activeClient

    final text = _textController.text.trim();

    final message = {
      "type": "private_message",
      "recipientId": widget.opponentId,
      "text": text,
      if (_replyingToMessage != null)
        "replyToId": _replyingToMessage!.messagesId,
    };

    _activeClient!.add(jsonEncode(message)); // Use _activeClient

    _textController.clear();

    _scrollToBottom();
  }

  /// ----------------------------------------
  /// Scroll helper
  /// ----------------------------------------
  void _scrollToMessage(String messageId) {
    final index = messages.indexWhere((m) => m.messagesId == messageId);
    if (index != -1) {
      // This is a simplification. For a robust solution, you might need
      // a package like scroll_to_index to handle cases where the item
      // isn't rendered yet.
      _scrollController.jumpTo(index * 56.0); // Assuming average item height
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        0,
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
    _localClient?.close(); // Close local client if it was created
    _localStreamController?.close(); // Close local stream controller
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
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, i) {
                if (i == messages.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final msg = messages[i];
                final isMe = msg.senderWorkerId != null;
                final isActive = _activeMessageId == msg.messagesId;

                return Slidable(
                  key: ValueKey("${msg.messagesId}_$resetKey"),
                  startActionPane: ActionPane(
                    motion: const StretchMotion(),

                    openThreshold: 0.99,
                    dismissible: DismissiblePane(
                      dismissThreshold: 0.5,
                      onDismissed:
                          () {}, // 這裡是必填的，但在這個情境下不會真的執行到，因為下面會 return false
                      confirmDismiss: () async {
                        // 1. 在這裡執行你的回覆邏輯
                        setState(() {
                          _replyingToMessage = msg;
                          resetKey = DateTime.now().toString();
                        });
                        // 2. 回傳 false，代表「不要刪除」這個 Item，它會自動彈回去
                        return false;
                      },
                    ),
                    children: [
                      SlidableAction(
                        onPressed: null,
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.grey,
                        icon: Icons.reply,
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onLongPress: () => _showContextMenu(context, msg),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      color: isActive ? Colors.grey[500] : Colors.transparent,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (msg.replySnippet != null)
                              GestureDetector(
                                onTap: () => _scrollToMessage(
                                  msg.replySnippet!.messagesId,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? Colors.blue[50]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        msg.replySnippet!.content,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (msg.gig != null)
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => GigDetail(
                                        gigId: msg.gig!.gigId,
                                        title: msg.gig!.title,
                                        sessionKey: widget.sessionKey,
                                        clearSessionKey:
                                            () {}, // Provide a dummy function as it's not used here
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? Colors.blue[50]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        msg.gig!.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${DateFormat("yyyy-MM-dd").format(msg.gig!.dateStart.toLocal())} - ${DateFormat("yyyy-MM-dd").format(msg.gig!.dateEnd.toLocal())}',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        '${msg.gig!.timeStart} - ${msg.gig!.timeEnd}',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        '地址: ${msg.gig!.city}${msg.gig!.district}${msg.gig!.address}',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            Text(msg.content),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat(
                                "yyyy-MM-dd HH:mm",
                              ).format(msg.createdAt.toLocal()),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  void _showContextMenu(BuildContext context, Message message) async {
    setState(() {
      _activeMessageId = message.messagesId;
    });

    final isMe = message.senderWorkerId != null; // Simplified check
    final canRetract =
        DateTime.now().difference(message.createdAt).inHours <= 3;

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
                    icon: Icons.copy,
                    label: '複製',
                    backgroundColor: Colors.blue[100]!,
                    iconColor: Colors.blue[700]!,
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: message.content));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('已複製')));
                    },
                  ),
                  if (isMe && canRetract)
                    _buildMenuOption(
                      icon: Icons.undo,
                      label: '撤回',
                      backgroundColor: Colors.orange[100]!,
                      iconColor: Colors.orange[700]!,
                      onTap: () {
                        Navigator.pop(context);
                        _confirmAction(
                          context,
                          '撤回訊息',
                          '您確定要撤回此訊息嗎？此操作將從雙方裝置中刪除訊息',
                          () => _retractMessage(message.messagesId),
                        );
                      },
                    ),
                  _buildMenuOption(
                    icon: Icons.delete_outline,
                    label: '刪除',
                    backgroundColor: Colors.red[100]!,
                    iconColor: Colors.red[700]!,
                    onTap: () {
                      Navigator.pop(context);
                      _confirmAction(
                        context,
                        '刪除訊息',
                        '您確定要刪除此訊息嗎？此操作僅會從您的裝置中刪除訊息，對方仍然可以查看',
                        () => _deleteMessage(message.messagesId),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    setState(() {
      _activeMessageId = null;
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

  // New method for confirmation dialog
  Future<void> _confirmAction(
    BuildContext context,
    String title,
    String content,
    Function onConfirm,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content, style: TextStyle(fontSize: 16)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
                onConfirm(); // Execute the confirmed action
              },
            ),
          ],
        );
      },
    );
  }

  void _retractMessage(String messageId) {
    if (widget.client == null) return;

    final message = {
      "type": "retract_message",
      "messageId": messageId,
      "recipientId": widget.opponentId,
    };

    widget.client!.add(jsonEncode(message));
  }

  Future<void> _deleteMessage(String messageId) async {
    final response = await Utils.client.delete(
      "/chat/messages/$messageId",
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        messages.removeWhere((m) => m.messagesId == messageId);
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete message')));
    }
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          if (_replyingToMessage != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Replying to ${_replyingToMessage!.senderWorkerId != null ? "Opponent" : "Me"}', // Simplified
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _replyingToMessage!.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _replyingToMessage = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 6,
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Send a message...',
                    ),
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
