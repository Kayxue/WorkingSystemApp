import 'package:json_annotation/json_annotation.dart';
import 'Notification.dart';
import 'NotificationPagination.dart';

part 'NotificationReturn.g.dart';

@JsonSerializable(explicitToJson: true)
class NotificationReturn {
  List<Notification> notifications;
  NotificationPagination pagination;

  NotificationReturn({
    required this.notifications,
    required this.pagination,
  });

  factory NotificationReturn.fromJson(Map<String, dynamic> json) =>
      _$NotificationReturnFromJson(json);
  
  Map<String, dynamic> toJson() => _$NotificationReturnToJson(this);
}