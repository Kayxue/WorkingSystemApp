import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart';
import 'package:working_system_app/Others/Constant.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/src/rust/api/websocket.dart';

/// Mixin to handle common WebSocket logic for chat functionality
/// Used by both ConversationList and ChattingRoom
mixin ChatWebSocketMixin<T extends StatefulWidget> on State<T> {
  WebSocketClient? chatWebSocket;
  String chatStatus = 'Disconnected';
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

      // Create the Rust WebSocket client
      chatWebSocket = WebSocketClient();

      // Set up message handler before connecting
      chatWebSocket!.onText((text) async {
        debugPrint('📨 Received message: $text');
        _chatStreamController?.add(text);
      });

      // Set up connection handler
      chatWebSocket!.onConnect(() async {
        debugPrint('✅ WebSocket connected');
        // Send authentication message after connection
        chatWebSocket!.sendText(jsonEncode({"type": "auth", "token": token}));

        if (mounted) {
          setState(() {
            chatStatus = 'Connected';
          });
        }

        // Set up listeners after connection is established
        _setupChatWebSocketListeners();
      });

      // Set up close handler
      chatWebSocket!.onClose((frame) async {
        debugPrint('❌ WebSocket closed: ${frame?.reason ?? "Unknown reason"}');
        if (mounted) {
          setState(() {
            chatStatus = 'Disconnected';
            chatWebSocket = null;
          });
        }
      });

      // Set up disconnect handler
      chatWebSocket!.onDisconnect(() async {
        debugPrint('🔌 WebSocket disconnected');
        if (mounted) {
          setState(() {
            chatStatus = 'Disconnected';
            chatWebSocket = null;
          });
        }
      });

      // Set up error handler
      chatWebSocket!.onConnectionFailed((error) async {
        debugPrint('⚠️ WebSocket connection failed: ${error.message}');
        if (mounted) {
          setState(() {
            chatStatus = 'Error';
            chatWebSocket = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to connect to chat: ${error.message}'),
            ),
          );
        }
      });

      // Connect to the WebSocket server
      await chatWebSocket!.connectTo(
        "wss://${Constant.backendUrl.substring(8)}/chat/ws",
      );

      debugPrint('🔄 Connecting to chat WebSocket...');
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

    // Listen to the stream for heartbeat handling and message processing
    _chatStreamSubscription = _chatStreamController?.stream.listen((message) {
      try {
        final body = jsonDecode(message) as Map<String, dynamic>;

        // Handle heartbeat
        if (body['type'] == 'heartbeat_request') {
          chatWebSocket?.sendText(jsonEncode({"type": "heartbeat"}));
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

    // The Rust WebSocket will automatically close via Drop trait
    chatWebSocket = null;

    _chatStreamController?.close();
    _chatStreamController = null;
  }

  /// Check if WebSocket is connected
  bool get isChatWebSocketConnected => chatWebSocket != null;
}
