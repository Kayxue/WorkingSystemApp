import 'package:json_annotation/json_annotation.dart';

part 'Notification.g.dart';

@JsonSerializable()
class Notification {
  String notificationId;
  String title;
  String message;
  String type;
  bool isRead;
  String createdAt;
  String resourceId;

  Notification({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.resourceId = '',
  });

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationToJson(this);
}