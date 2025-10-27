import 'dart:convert';
import 'package:rhttp/rhttp.dart';
import 'package:flutter/material.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Types/JSONObject/NotificationReturn.dart';
import 'package:working_system_app/Widget/LoadingIndicator.dart';
import 'package:working_system_app/Types/JSONObject/Notification.dart' as NotificationType;

class NotificationPage extends StatefulWidget {
  final String sessionKey;
  const NotificationPage({
    super.key,
    required this.sessionKey,
  });

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
        headers: HttpHeaders.rawMap({
          'cookie': widget.sessionKey,
        }),
      );

      if (response.statusCode == 200) {
        final notificationReturn =
            NotificationReturn.fromJson(jsonDecode(response.body)['data']);
        setState(() {
          _notifications.addAll(notificationReturn.notifications);
          _hasMore = notificationReturn.pagination.hasMore;
          _offset = _notifications.length;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notifications',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _notifications = [];
                  _offset = 0;
                  _hasMore = true;
                });
                await _fetchNotifications();
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _notifications.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _notifications.length) {
                    return const LoadingIndicator();
                  }
                  final notification = _notifications[index];
                  return ListTile(
                    leading: Icon(_getIconForType(notification.type)),
                    title: Text(notification.title),
                    subtitle: Text(notification.message),
                    trailing: notification.isRead
                        ? null
                        : const Icon(
                            Icons.circle,
                            color: Colors.blue,
                            size: 12,
                          ),
                    onTap: () {

                    },
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
