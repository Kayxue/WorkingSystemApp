import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/EmployerPhoto.dart';

part 'Employer.g.dart';

@JsonSerializable(explicitToJson: true)
class Employer {
  String employerId;
  String employerName;
  String branchName;
  String industryType;
  String address;
  dynamic employerPhoto;

  Employer({
    required this.employerId,
    required this.employerName,
    required this.branchName,
    required this.industryType,
    required this.address,
    this.employerPhoto,
  });

  factory Employer.fromJson(Map<String, dynamic> json) =>
      _$EmployerFromJson(json);

  Map<String, dynamic> toJson() => _$EmployerToJson(this);
}
