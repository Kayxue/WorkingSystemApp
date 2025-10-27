// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'WorkerReviewEmployer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkerReviewEmployer _$WorkerReviewEmployerFromJson(
  Map<String, dynamic> json,
) =>
    WorkerReviewEmployer(
        employerId: json['employerId'] as String,
        name: json['name'] as String,
      )
      ..employerPhoto = json['employerPhoto'] == null
          ? null
          : ProfilePhoto.fromJson(
              json['employerPhoto'] as Map<String, dynamic>,
            );

Map<String, dynamic> _$WorkerReviewEmployerToJson(
  WorkerReviewEmployer instance,
) => <String, dynamic>{
  'employerId': instance.employerId,
  'name': instance.name,
  'employerPhoto': instance.employerPhoto?.toJson(),
};
