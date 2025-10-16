import 'package:json_annotation/json_annotation.dart';

part 'Application.g.dart';

@JsonSerializable()
class Application {
  String applicationId;
  String gigId;
  String gigTitle;
  String employerName;
  int hourlyRate; 
  String workDate;
  String workTime;
  String status;
  String appliedAt;

  Application({
    required this.applicationId,
    required this.gigId,
    required this.gigTitle,
    required this.employerName,
    required this.hourlyRate,
    required this.workDate,
    required this.workTime,
    required this.status,
    required this.appliedAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) =>
      _$ApplicationFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationToJson(this);
}
