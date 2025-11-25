import 'package:json_annotation/json_annotation.dart';
import 'notification.dart';
import 'notification_pagination.dart';

part 'notification_return.g.dart';

@JsonSerializable(explicitToJson: true)
class NotificationReturn {
  List<Notification> notifications;
  NotificationPagination pagination;

  NotificationReturn({required this.notifications, required this.pagination});

  factory NotificationReturn.fromJson(Map<String, dynamic> json) =>
      _$NotificationReturnFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationReturnToJson(this);
}
