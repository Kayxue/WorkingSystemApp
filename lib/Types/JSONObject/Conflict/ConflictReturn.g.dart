// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ConflictReturn.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConflictReturn _$ConflictReturnFromJson(Map<String, dynamic> json) =>
    ConflictReturn(
      application: CurrentApplication.fromJson(
        json['application'] as Map<String, dynamic>,
      ),
      confirmedGigConflicts:
          (json['confirmedGigConflicts'] as List<dynamic>?)
              ?.map((e) => ConfirmedGig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pendingApplicationConflicts:
          (json['pendingApplicationConflicts'] as List<dynamic>?)
              ?.map(
                (e) => PendingApplication.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      pagination: ApplicationPagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$ConflictReturnToJson(ConflictReturn instance) =>
    <String, dynamic>{
      'application': instance.application.toJson(),
      'confirmedGigConflicts': instance.confirmedGigConflicts
          .map((e) => e.toJson())
          .toList(),
      'pendingApplicationConflicts': instance.pendingApplicationConflicts
          .map((e) => e.toJson())
          .toList(),
      'pagination': instance.pagination.toJson(),
    };
