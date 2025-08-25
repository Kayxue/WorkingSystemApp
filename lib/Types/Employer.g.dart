// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Employer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employer _$EmployerFromJson(Map<String, dynamic> json) => Employer(
  employerId: json['employerId'] as String,
  employerName: json['employerName'] as String,
  branchName: json['branchName'] as String,
  industryType: json['industryType'] as String,
  address: json['address'] as String,
  employerPhoto: json['employerPhoto'],
);

Map<String, dynamic> _$EmployerToJson(Employer instance) => <String, dynamic>{
  'employerId': instance.employerId,
  'employerName': instance.employerName,
  'branchName': instance.branchName,
  'industryType': instance.industryType,
  'address': instance.address,
  'employerPhoto': instance.employerPhoto,
};
