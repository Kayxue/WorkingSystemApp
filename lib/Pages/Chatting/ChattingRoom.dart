import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart';
import 'package:working_system_app/Others/Constant.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/src/rust/api/websocket.dart';

class ChattingRoom extends StatefulWidget {
  final String sessionKey;

  const ChattingRoom({super.key, required this.sessionKey});

  @override
  State<ChattingRoom> createState() => _ChattingRoomState();
}

class _ChattingRoomState extends State<ChattingRoom> {
  WebSocketClient? client;
  String status = 'Disconnected';

  @override
  void initState() {
    super.initState();
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
    print("  📝 Registering onConnect...");
    client!.onConnect(() async {
      print("✅✅✅ ON_CONNECT CALLBACK FIRED! ✅✅✅");
      await client!.sendText("{\"type\":\"auth\", \"token\":\"$token\"}");
      if (mounted) {
        setState(() {
          status = 'Connected';
        });
      }
    });

    print("  📝 Registering onText...");
    client!.onText((message) async {
      print("✅✅✅ ON_TEXT CALLBACK FIRED! Message: $message");
      final body = jsonDecode(message) as Map<String, dynamic>;
      if (body['type'] == 'heartbeat_request') {
        print("Received pong, sending ping...");
        await client!.sendText("{\"type\":\"heartbeat\"}");
      }
    });

    print("  📝 Registering onDisconnect...");
    client!.onDisconnect(() async {
      print("✅✅✅ ON_DISCONNECT CALLBACK FIRED!");
      if (mounted) {
        setState(() {
          status = 'Disconnected';
          client = null;
        });
      }
    });

    print("  📝 Registering onClose...");
    client!.onClose((closeFrame) async {
      print("✅✅✅ ON_CLOSE CALLBACK FIRED! Reason: ${closeFrame?.reason}");
      if (mounted) {
        setState(() {
          status = 'Connection Closed: ${closeFrame?.reason}';
          client = null;
        });
      }
    });

    print("  📝 Registering onConnectionFailed...");
    client!.onConnectionFailed((error) async {
      print("✅✅✅ ON_CONNECTION_FAILED CALLBACK FIRED! Error: ${error.message}");
      if (mounted) {
        setState(() {
          status = 'Connection Failed: ${error.message}';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chatting Room')),
      body: Column(
        children: [
          Text('Status: $status'),
          ElevatedButton(
            onPressed: () async {
              // TEST: This should print immediately
              print("🔘🔘🔘 BUTTON PRESSED! 🔘🔘🔘");
              debugPrint("🔘🔘🔘 BUTTON PRESSED! 🔘🔘🔘");

              if (client != null) {
                print("⚠️ Already have a client");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Already connected')),
                );
                return;
              }

              print("📱 Getting token...");
              final token = await getToken();
              print("📱 Token received: ${token.isEmpty ? 'EMPTY' : 'Got it'}");
              if (token.isEmpty) return;

              print("📱 Creating WebSocketClient...");
              client = WebSocketClient();
              print("✓ Client created");

              print("📱 Adding event listeners...");
              addEventListeners(token);
              final result = client!.getListenersStatus();
              print("✓ Listeners status: $result");
              print("✓ Event listeners added");

              print("📱 About to call connectTo()...");
              // ✅ CRITICAL FIX: Add await!
              await client!.connectTo(
                "wss://${Constant.backendUrl.substring(8)}/chat/ws",
              );
              print("✅ connectTo() completed!");
            },
            child: const Text('Connect to Chat Server'),
          ),
        ],
      ),
    );
  }
}
