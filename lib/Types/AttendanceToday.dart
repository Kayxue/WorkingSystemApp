import 'package:json_annotation/json_annotation.dart';
import 'AttendanceGigInfo.dart';

part 'AttendanceToday.g.dart';

@JsonSerializable(explicitToJson: true)
class AttendanceToday {
  String date;
  List<AttendanceGigInfo> jobs;
  int total;

  AttendanceToday({
    required this.date,
    required this.jobs,
    required this.total,
  });

  factory AttendanceToday.fromJson(Map<String, dynamic> json) =>
      _$AttendanceTodayFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceTodayToJson(this);
}
