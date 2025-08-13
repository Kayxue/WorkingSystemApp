// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GigDetails.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gigdetails _$GigdetailsFromJson(Map<String, dynamic> json) => Gigdetails(
  gigId: json['gigId'] as String,
  employerId: json['employerId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  dateStart: DateTime.parse(json['dateStart'] as String),
  dateEnd: DateTime.parse(json['dateEnd'] as String),
  timeStart: json['timeStart'] as String,
  timeEnd: json['timeEnd'] as String,
  requirements: json['requirements'] as Map<String, dynamic>,
  hourlyRate: (json['hourlyRate'] as num).toInt(),
  city: json['city'] as String,
  district: json['district'] as String,
  address: json['address'] as String,
  environmentPhotos: (json['environmentPhotos'] as List<dynamic>?)
      ?.map((e) => Environmentphoto.fromJson(e as Map<String, dynamic>))
      .toList(),
  contactPerson: json['contactPerson'] as String,
  contactPhone: json['contactPhone'] as String?,
  contactEmail: json['contactEmail'] as String?,
  publishedAt: DateTime.parse(json['publishedAt'] as String),
  unlistedAt: json['unlistedAt'] == null
      ? null
      : DateTime.parse(json['unlistedAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  employer: Employer.fromJson(json['employer'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GigdetailsToJson(Gigdetails instance) =>
    <String, dynamic>{
      'gigId': instance.gigId,
      'employerId': instance.employerId,
      'title': instance.title,
      'description': instance.description,
      'dateStart': instance.dateStart.toIso8601String(),
      'dateEnd': instance.dateEnd.toIso8601String(),
      'timeStart': instance.timeStart,
      'timeEnd': instance.timeEnd,
      'requirements': instance.requirements,
      'hourlyRate': instance.hourlyRate,
      'city': instance.city,
      'district': instance.district,
      'address': instance.address,
      'environmentPhotos': instance.environmentPhotos
          ?.map((e) => e.toJson())
          .toList(),
      'contactPerson': instance.contactPerson,
      'contactPhone': instance.contactPhone,
      'contactEmail': instance.contactEmail,
      'publishedAt': instance.publishedAt.toIso8601String(),
      'unlistedAt': instance.unlistedAt?.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'employer': instance.employer.toJson(),
    };
