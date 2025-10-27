// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'WorkerReviewReturn.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkerReviewReturn _$WorkerReviewReturnFromJson(Map<String, dynamic> json) =>
    WorkerReviewReturn(
      ratableGigs: (json['ratableGigs'] as List<dynamic>)
          .map((e) => WorkerReview.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$WorkerReviewReturnToJson(WorkerReviewReturn instance) =>
    <String, dynamic>{
      'ratableGigs': instance.ratableGigs.map((e) => e.toJson()).toList(),
      'pagination': instance.pagination.toJson(),
    };
