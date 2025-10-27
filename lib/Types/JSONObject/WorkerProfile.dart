import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/ProfilePhoto.dart';
import 'package:working_system_app/Types/JSONObject/RatingStats.dart';

part 'WorkerProfile.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkerProfile {
  String workerId;
  String email;
  String firstName;
  String lastName;
  String phoneNumber;
  String highestEducation;
  String? schoolName;
  String? major;
  String studyStatus;
  List<String>? certificates;
  List<String> jobExperience;
  DateTime createdAt;
  DateTime updatedAt;
  String role;
  String userId;
  ProfilePhoto? profilePhoto;
  RatingStats ratingStats;

  WorkerProfile({
    required this.workerId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.highestEducation,
    this.schoolName,
    this.major,
    required this.studyStatus,
    this.certificates,
    required this.jobExperience,
    required this.createdAt,
    required this.updatedAt,
    required this.role,
    required this.userId,
    this.profilePhoto,
    required this.ratingStats,
  });

  WorkerProfile.clone(WorkerProfile origin)
    : this(
        workerId: origin.workerId,
        email: origin.email,
        firstName: origin.firstName,
        lastName: origin.lastName,
        phoneNumber: origin.phoneNumber,
        highestEducation: origin.highestEducation,
        schoolName: origin.schoolName,
        major: origin.major,
        studyStatus: origin.studyStatus,
        certificates: origin.certificates == null
            ? null
            : List<String>.from(origin.certificates!),
        jobExperience: List<String>.from(origin.jobExperience),
        createdAt: origin.createdAt,
        updatedAt: origin.updatedAt,
        role: origin.role,
        userId: origin.userId,
        profilePhoto: origin.profilePhoto,
        ratingStats: RatingStats.clone(origin.ratingStats),
      );

  factory WorkerProfile.fromJson(Map<String, dynamic> json) =>
      _$WorkerProfileFromJson(json);

  Map<String, dynamic> toJson() => _$WorkerProfileToJson(this);
}
