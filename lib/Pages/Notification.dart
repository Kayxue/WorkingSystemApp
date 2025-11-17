import 'dart:convert';
import 'package:rhttp/rhttp.dart';
import 'package:flutter/material.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Pages/Chatting/ConversationList.dart';
import 'package:working_system_app/Types/JSONObject/NotificationReturn.dart';
import 'package:working_system_app/Widget/Others/LoadingIndicator.dart';
import 'package:working_system_app/Types/JSONObject/Notification.dart'
    as NotificationType;
import 'package:working_system_app/Pages/MyApplications.dart';

class NotificationPage extends StatefulWidget {
  final String sessionKey;
  const NotificationPage({super.key, required this.sessionKey});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;
  List<NotificationType.Notification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchNotifications();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchNotifications() async {
    if (_isLoading || !_hasMore) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Utils.client.get(
        '/notifications/list?limit=$_limit&offset=$_offset',
        headers: HttpHeaders.rawMap({'cookie': widget.sessionKey}),
      );

      if (response.statusCode == 200) {
        final notificationReturn = NotificationReturn.fromJson(
          jsonDecode(response.body)['data'],
        );
        setState(() {
          _notifications.addAll(notificationReturn.notifications);
          _hasMore = notificationReturn.pagination.hasMore;
          _offset = _notifications.length;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  void mark(List<String> notificationId, String action) async {
    try {
      final response = await Utils.client.put(
        '/notifications/mark-as-read?isRead=${action == "markRead" ? "true" : "false"}',
        headers: HttpHeaders.rawMap({'cookie': widget.sessionKey}),
        body: HttpBody.json({"notificationIds": notificationId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          for (var notif in _notifications) {
            if (notificationId.contains(notif.notificationId)) {
              notif.isRead = action == "markRead" ? true : false;
            }
          }
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteNotifications(String NotificationId) async {
    try {
      final response = await Utils.client.delete(
        '/notifications/${NotificationId}',
        headers: HttpHeaders.rawMap({'cookie': widget.sessionKey}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _notifications.removeWhere(
            (notification) => notification.notificationId == NotificationId,
          );
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  String formatTimeAgo(String createdAt) {
    final now = DateTime.now();
    final notificationTime = DateTime.parse(createdAt);
    final difference = now.difference(notificationTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}hours';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'just now';
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'application':
        return Icons.work;
      case 'rating':
        return Icons.star;
      case 'account':
        return Icons.person;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _notifications = [];
          _offset = 0;
          _hasMore = true;
        });
        await _fetchNotifications();
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.message),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ConversationList(sessionKey: widget.sessionKey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == _notifications.length) {
                return const LoadingIndicator();
              }
              final notification = _notifications[index];
              return Stack(
                children: [
                  ListTile(
                    tileColor: notification.isRead
                        ? Colors.transparent
                        : Colors.blue.shade50,
                    leading: Icon(_getIconForType(notification.type)),
                    title: Text(
                      notification.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.message),
                        const SizedBox(height: 4),
                        Text(
                          formatTimeAgo(notification.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: const SizedBox(width: 20),
                    onTap: () {
                      mark([notification.notificationId], "markRead");
                      if (notification.type == 'application') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                MyApplications(sessionKey: widget.sessionKey),
                          ),
                        );
                      }
                    },
                  ),
                  Positioned(
                    top: 8.0,
                    right: 0,
                    child: IconButton(
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        _getIconForType(notification.type),
                                        size: 40.0,
                                      ),
                                      const SizedBox(height: 12.0),
                                      Text(
                                        notification.title,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        notification.message,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.mark_email_read),
                                  title: const Text('Mark as Read'),
                                  onTap: () {
                                    mark([
                                      notification.notificationId,
                                    ], "markRead");
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.mark_email_unread),
                                  title: const Text('Mark as Unread'),
                                  onTap: () {
                                    mark([
                                      notification.notificationId,
                                    ], "markUnread");
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.delete_forever),
                                  title: const Text('Delete'),
                                  onTap: () {
                                    deleteNotifications(
                                      notification.notificationId,
                                    );
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.more_horiz),
                    ),
                  ),
                ],
              );
            }, childCount: _notifications.length + (_hasMore ? 1 : 0)),
          ),
        ],
      ),
    );
  }
}
