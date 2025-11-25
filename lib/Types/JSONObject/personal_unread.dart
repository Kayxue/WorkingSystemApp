import 'package:json_annotation/json_annotation.dart';

part 'personal_unread.g.dart';

@JsonSerializable(explicitToJson: true)
class PersonalUnread {
  int pendingJobs;
  int unratedEmployers;
  int unreadMessages;

  PersonalUnread({
    required this.pendingJobs,
    required this.unratedEmployers,
    required this.unreadMessages,
  });

  factory PersonalUnread.fromJson(Map<String, dynamic> json) =>
      _$PersonalUnreadFromJson(json);
  Map<String, dynamic> toJson() => _$PersonalUnreadToJson(this);
}