import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:rhttp/rhttp.dart';
import 'package:flutter/material.dart';
import 'package:working_system_app/Others/Constant.dart';
import 'package:working_system_app/Others/Utils.dart';

/// Mixin to handle common WebSocket logic for chat functionality
/// Used by both ConversationList and ChattingRoom
mixin ChatWebSocketMixin<T extends StatefulWidget> on State<T> {
  WebSocket? chatWebSocket;
  StreamController<dynamic>? _chatStreamController;
  StreamSubscription? _chatStreamSubscription;

  /// Stream for listening to WebSocket messages
  Stream<dynamic>? get chatStream => _chatStreamController?.stream;

  /// Session key for authentication - must be provided by the widget
  String get sessionKey;

  /// Get WebSocket authentication token from the server
  Future<String> getChatToken() async {
    try {
      final response = await Utils.client.get(
        "/chat/ws-token",
        headers: HttpHeaders.rawMap({
          "platform": "mobile",
          "cookie": sessionKey,
        }),
      );

      if (!mounted) return '';

      if (response.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get WebSocket token')),
          );
        }
        return '';
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['token'] as String;
    } catch (e) {
      debugPrint('Error getting chat token: $e');
      return '';
    }
  }

  /// Connect to the chat WebSocket
  Future<void> connectChatWebSocket() async {
    if (chatWebSocket != null) return;

    final token = await getChatToken();
    if (token.isEmpty) return;

    try {
      _chatStreamController = StreamController<dynamic>.broadcast();

      chatWebSocket = await WebSocket.connect(
        "wss://${Constant.backendUrl.substring(8)}/chat/ws",
      );

      // Send authentication message
      chatWebSocket!.add(jsonEncode({"type": "auth", "token": token}));

      if (mounted) {
        setState(() {
          // WebSocket connected
        });
      }

      // Set up listeners
      _setupChatWebSocketListeners();
    } catch (e) {
      debugPrint('Error connecting to chat WebSocket: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to chat: $e')),
        );
      }
    }
  }

  /// Set up WebSocket listeners
  void _setupChatWebSocketListeners() {
    if (chatWebSocket == null || _chatStreamController == null) return;

    chatWebSocket!.listen(
      (message) {
        _chatStreamController?.add(message);
      },
      onDone: () {
        if (mounted) {
          setState(() {
            chatWebSocket = null;
          });
        }
        _chatStreamController?.close();
        _chatStreamController = null;
      },
      onError: (error) {
        debugPrint("WebSocket error: $error");
        _chatStreamController?.addError(error);
      },
    );

    // Listen to the stream for heartbeat handling
    _chatStreamSubscription = _chatStreamController?.stream.listen((message) {
      try {
        final body = jsonDecode(message) as Map<String, dynamic>;

        // Handle heartbeat
        if (body['type'] == 'heartbeat_request') {
          chatWebSocket?.add(jsonEncode({"type": "heartbeat"}));
        }

        // Call the custom message handler
        onChatMessage(body);
      } catch (e) {
        debugPrint('Error handling chat message: $e');
      }
    });

    // Notify that listeners are ready
    onWebSocketConnected();
  }

  /// Override this method to be notified when WebSocket is connected and ready
  void onWebSocketConnected() {
    // Default implementation does nothing
    // Override in the widget if needed
  }

  /// Override this method to handle specific message types in the implementing widget
  void onChatMessage(Map<String, dynamic> message) {
    // Default implementation does nothing
    // Override in the widget to handle specific messages
  }

  /// Close the WebSocket connection
  void closeChatWebSocket() {
    _chatStreamSubscription?.cancel();
    _chatStreamSubscription = null;

    chatWebSocket?.close();
    chatWebSocket = null;

    _chatStreamController?.close();
    _chatStreamController = null;
  }

  /// Check if WebSocket is connected
  bool get isChatWebSocketConnected => chatWebSocket != null;
}
