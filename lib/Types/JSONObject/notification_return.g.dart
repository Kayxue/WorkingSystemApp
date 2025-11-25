// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_return.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationReturn _$NotificationReturnFromJson(Map<String, dynamic> json) =>
    NotificationReturn(
      notifications: (json['notifications'] as List<dynamic>)
          .map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: NotificationPagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$NotificationReturnToJson(NotificationReturn instance) =>
    <String, dynamic>{
      'notifications': instance.notifications.map((e) => e.toJson()).toList(),
      'pagination': instance.pagination.toJson(),
    };
