import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:rhttp/rhttp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Types/JSONObject/Message/Message.dart';
import 'package:working_system_app/Types/JSONObject/Message/ReplySnippet.dart';

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
  Message? _replyingToMessage;
  String resetKey = "";

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
            content: 'Message retracted',
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
    if (_textController.text.trim().isEmpty || widget.client == null) return;

    final text = _textController.text.trim();

    final message = {
      "type": "private_message",
      "recipientId": widget.opponentId,
      "text": text,
      if (_replyingToMessage != null) "replyToId": _replyingToMessage!.messagesId,
    };

    widget.client!.add(jsonEncode(message));

    // optimistic insert
    final optimistic = Message(
      messagesId: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: widget.conversationId,
      content: text,
      createdAt: DateTime.now(),
      senderWorkerId: null, // Assuming the user is a worker
      senderEmployerId: null,
      replyToId: _replyingToMessage?.messagesId,
      replySnippet: _replyingToMessage != null
          ? ReplySnippet(
              messagesId: _replyingToMessage!.messagesId,
              content: _replyingToMessage!.content,
              createdAt: _replyingToMessage!.createdAt,
            )
          : null,
    );

    setState(() {
      messages.insert(0, optimistic);
      _replyingToMessage = null;
    });

    _textController.clear();
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

                return Slidable(
                  key: ValueKey("${msg.messagesId}_$resetKey"),
                  startActionPane: ActionPane(
                    motion: const StretchMotion(),
                    openThreshold: 0.99,
                    dismissible: DismissiblePane(
                      dismissThreshold: 0.5,
                      onDismissed: () {}, // 這裡是必填的，但在這個情境下不會真的執行到，因為下面會 return false
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
                            if (msg.replySnippet != null)
                              GestureDetector(
                                onTap: () => _scrollToMessage(msg.replySnippet!.messagesId),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: isMe ? Colors.blue[50] : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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

  void _showContextMenu(BuildContext context, Message message) {
    final isMe = message.senderWorkerId != null; // Simplified check
    final canRetract = DateTime.now().difference(message.createdAt).inHours <= 3;

    showModalBottomSheet(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.reply),
                title: Text('Reply'),
                onTap: () {
                  setState(() {
                    _replyingToMessage = message;
                  });
                  Navigator.pop(context);
                },
              ),
              if (isMe)
                ListTile(
                  leading: Icon(Icons.undo),
                  title: Text('Retract'),
                  onTap: canRetract
                      ? () {
                          _retractMessage(message.messagesId);
                          Navigator.pop(context);
                        }
                      : null,
                ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
                onTap: () {
                  _deleteMessage(message.messagesId);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete message')),
      );
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
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
