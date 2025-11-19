import 'package:json_annotation/json_annotation.dart';

part 'GigReturnForMessage.g.dart';

@JsonSerializable()
class GigReturnForMessage {
  String gigId;
  String employerId;
  String title;
  DateTime dateStart;
  DateTime dateEnd;
  String timeStart;
  String timeEnd;
  String city;
  String district;
  String address;

  GigReturnForMessage({
    required this.gigId,
    required this.employerId,
    required this.title,
    required this.dateStart,
    required this.dateEnd,
    required this.timeStart,
    required this.timeEnd,
    required this.city,
    required this.district,
    required this.address,
  });

  factory GigReturnForMessage.fromJson(Map<String, dynamic> json) =>
      _$GigReturnForMessageFromJson(json);
  Map<String, dynamic> toJson() => _$GigReturnForMessageToJson(this);
}