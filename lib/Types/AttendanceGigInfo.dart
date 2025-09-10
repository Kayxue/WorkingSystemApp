import 'package:json_annotation/json_annotation.dart';

part 'AttendanceGigInfo.g.dart';

@JsonSerializable()
class AttendanceGigInfo {
  String gigId;
  String title;
  String timeStart;
  String timeEnd;
  String city;
  String district;
  String address;

  AttendanceGigInfo({
    required this.gigId,
    required this.title,
    required this.timeStart,
    required this.timeEnd,
    required this.city,
    required this.district,
    required this.address,
  });

  factory AttendanceGigInfo.fromJson(Map<String, dynamic> json) =>
      _$AttendanceGigInfoFromJson(json);
  
  Map<String, dynamic> toJson() => _$AttendanceGigInfoToJson(this);
}