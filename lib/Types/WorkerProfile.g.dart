// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'WorkerProfile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkerProfile _$WorkerProfileFromJson(Map<String, dynamic> json) =>
    WorkerProfile(
      workerId: json['workerId'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      highestEducation: json['highestEducation'] as String,
      schoolName: json['schoolName'] as String?,
      major: json['major'] as String?,
      studyStatus: json['studyStatus'] as String,
      certificates: (json['certificates'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      jobExperience: (json['jobExperience'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      role: json['role'] as String,
      userId: json['userId'] as String,
      profilePhoto: json['profilePhoto'] == null
          ? null
          : ProfilePhoto.fromJson(json['profilePhoto'] as Map<String, dynamic>),
      ratingStats: RatingStats.fromJson(
        json['ratingStats'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$WorkerProfileToJson(WorkerProfile instance) =>
    <String, dynamic>{
      'workerId': instance.workerId,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phoneNumber': instance.phoneNumber,
      'highestEducation': instance.highestEducation,
      'schoolName': instance.schoolName,
      'major': instance.major,
      'studyStatus': instance.studyStatus,
      'certificates': instance.certificates,
      'jobExperience': instance.jobExperience,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'role': instance.role,
      'userId': instance.userId,
      'profilePhoto': instance.profilePhoto?.toJson(),
      'ratingStats': instance.ratingStats.toJson(),
    };
