import 'package:json_annotation/json_annotation.dart';

part 'notification_pagination.g.dart';

@JsonSerializable()
class NotificationPagination {
  int limit;
  int offset;
  bool hasMore;
  int returned;

  NotificationPagination({
    required this.limit,
    required this.offset,
    required this.hasMore,
    required this.returned,
  });

  factory NotificationPagination.fromJson(Map<String, dynamic> json) =>
      _$NotificationPaginationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPaginationToJson(this);
}
