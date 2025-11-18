import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
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
  late final _pagingController = PagingController<int, ConversationChat>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) async {
      final result = await fetchConversations(page: pageKey);
      return result;
    },
  );

  Future<List<ConversationChat>> fetchConversations({int page = 1}) async {
    final response = await Utils.client.get(
      "/chat/conversations?page=$page",
      headers: .rawMap({"platform": "mobile", "cookie": widget.sessionKey}),
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
        padding: .only(top: 16, right: 16, left: 16, bottom: 8),
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
                    title: Text(item.opponent.name),
                    subtitle: Text(
                      item.lastMessage ?? 'No messages yet',
                      style: TextStyle(
                        color: item.lastMessage != null
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChattingRoom(
                        sessionKey: widget.sessionKey,
                        conversationId: item.conversationId,
                        opponentName: item.opponent.name,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
