// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PersonalUnread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonalUnread _$PersonalUnreadFromJson(Map<String, dynamic> json) =>
    PersonalUnread(
      pendingJobs: (json['pendingJobs'] as num).toInt(),
      unratedEmployers: (json['unratedEmployers'] as num).toInt(),
      unreadMessages: (json['unreadMessages'] as num).toInt(),
    );

Map<String, dynamic> _$PersonalUnreadToJson(PersonalUnread instance) =>
    <String, dynamic>{
      'pendingJobs': instance.pendingJobs,
      'unratedEmployers': instance.unratedEmployers,
      'unreadMessages': instance.unreadMessages,
    };
