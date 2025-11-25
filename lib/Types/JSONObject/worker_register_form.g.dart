// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_register_form.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkerRegisterForm _$WorkerRegisterFormFromJson(Map<String, dynamic> json) =>
    WorkerRegisterForm()
      ..firstName = json['firstName'] as String
      ..lastName = json['lastName'] as String
      ..email = json['email'] as String
      ..password = json['password'] as String
      ..phoneNumber = json['phoneNumber'] as String
      ..highestEducation = json['highestEducation'] as String
      ..schoolName = json['schoolName'] as String?
      ..major = json['major'] as String?
      ..studyStatus = json['studyStatus'] as String
      ..certificates = (json['certificates'] as List<dynamic>)
          .map((e) => e as String)
          .toList()
      ..jobExperience = (json['jobExperience'] as List<dynamic>)
          .map((e) => e as String)
          .toList();

Map<String, dynamic> _$WorkerRegisterFormToJson(WorkerRegisterForm instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'password': instance.password,
      'phoneNumber': instance.phoneNumber,
      'highestEducation': instance.highestEducation,
      'schoolName': instance.schoolName,
      'major': instance.major,
      'studyStatus': instance.studyStatus,
      'certificates': instance.certificates,
      'jobExperience': instance.jobExperience,
    };
