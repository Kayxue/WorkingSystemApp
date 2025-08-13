import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/Employer.dart';
import 'package:working_system_app/Types/EnvironmentPhoto.dart';
part 'GigDetails.g.dart';

@JsonSerializable(explicitToJson: true)
class Gigdetails {
  String gigId;
  String employerId;
  String title;
  String description;
  DateTime dateStart;
  DateTime dateEnd;
  String timeStart;
  String timeEnd;
  Map<String,dynamic> requirements;
  int hourlyRate;
  String city;
  String district;
  String address;
  List<Environmentphoto>? environmentPhotos;
  String contactPerson;
  String? contactPhone;
  String? contactEmail;
  DateTime publishedAt;
  DateTime? unlistedAt;
  DateTime updatedAt;
  Employer employer;

  Gigdetails({
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

  factory Gigdetails.fromJson(Map<String, dynamic> json) =>
      _$GigdetailsFromJson(json);
  Map<String, dynamic> toJson() => _$GigdetailsToJson(this);
}