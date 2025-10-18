import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/Employer.dart';
import 'package:working_system_app/Types/JSONObject/EnvironmentPhoto.dart';
import 'package:working_system_app/Types/JSONObject/Requirements.dart';

part 'GigDetails.g.dart';

@JsonSerializable(explicitToJson: true)
class GigDetails {
  String gigId;
  String employerId;
  String title;
  String description;
  DateTime dateStart;
  DateTime dateEnd;
  String timeStart;
  String timeEnd;
  Requirements requirements;
  int hourlyRate;
  String city;
  String district;
  String address;
  List<EnvironmentPhoto>? environmentPhotos;
  String contactPerson;
  String? contactPhone;
  String? contactEmail;
  DateTime publishedAt;
  DateTime? unlistedAt;
  DateTime updatedAt;
  Employer employer;

  GigDetails({
    required this.gigId,
    required this.employerId,
    required this.title,
    required this.description,
    required this.dateStart,
    required this.dateEnd,
    required this.timeStart,
    required this.timeEnd,
    required this.requirements,
    required this.hourlyRate,
    required this.city,
    required this.district,
    required this.address,
    required this.environmentPhotos,
    required this.contactPerson,
    this.contactPhone,
    this.contactEmail,
    required this.publishedAt,
    this.unlistedAt,
    required this.updatedAt,
    required this.employer,
  });

  factory GigDetails.fromJson(Map<String, dynamic> json) =>
      _$GigDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$GigDetailsToJson(this);
}
