import 'package:json_annotation/json_annotation.dart';

part 'PendingApplication.g.dart';

@JsonSerializable()
class PendingApplication {
  String applicationId;
  String gigId;
  String title;
  String dateStart;
  String dateEnd;
  String timeStart;
  String timeEnd;
  int hourlyRate;
  String employerName;
  String city;
  String district;
  String address;
  String status;

  PendingApplication({
    required this.applicationId,
    required this.gigId,
    required this.title,
    required this.dateStart,
    required this.dateEnd,
    required this.timeStart,
    required this.timeEnd,
    required this.hourlyRate,
    required this.employerName,
    required this.city,
    required this.district,
    required this.address,
    required this.status,
  });

  factory PendingApplication.fromJson(Map<String, dynamic> json) =>
      _$PendingApplicationFromJson(json);

  Map<String, dynamic> toJson() => _$PendingApplicationToJson(this);
}