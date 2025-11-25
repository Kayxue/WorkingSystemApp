import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Others/constant.dart';

part 'application.g.dart';

@JsonSerializable()
class Application {
  String applicationId;
  String gigId;
  String gigTitle;
  int hourlyRate;
  String employerName;
  String workDate;
  String workTime;
  ApplicationStatus status;
  String appliedAt;
  bool? hasConflict;
  bool? hasPendingConflict;

  Application({
    required this.applicationId,
    required this.gigId,
    required this.gigTitle,
    required this.hourlyRate,
    required this.employerName,
    required this.workDate,
    required this.workTime,
    required this.status,
    required this.appliedAt,
    required this.hasConflict,
    required this.hasPendingConflict,
  });

  factory Application.fromJson(Map<String, dynamic> json) =>
      _$ApplicationFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationToJson(this);
}
