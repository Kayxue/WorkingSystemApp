// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PublicGigsReturn.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicGigsReturn _$PublicGigsReturnFromJson(Map<String, dynamic> json) =>
    PublicGigsReturn(
      gigs: (json['gigs'] as List<dynamic>)
          .map((e) => Gigs.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
      filters: GigFilters.fromJson(json['filters'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PublicGigsReturnToJson(PublicGigsReturn instance) =>
    <String, dynamic>{
      'gigs': instance.gigs.map((e) => e.toJson()).toList(),
      'pagination': instance.pagination.toJson(),
      'filters': instance.filters.toJson(),
    };
