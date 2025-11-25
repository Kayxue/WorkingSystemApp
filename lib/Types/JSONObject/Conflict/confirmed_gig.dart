import 'package:json_annotation/json_annotation.dart';

part 'confirmed_gig.g.dart';

@JsonSerializable()
class ConfirmedGig {
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

  ConfirmedGig({
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
  });

  factory ConfirmedGig.fromJson(Map<String, dynamic> json) =>
      _$ConfirmedGigFromJson(json);

  Map<String, dynamic> toJson() => _$ConfirmedGigToJson(this);
}
