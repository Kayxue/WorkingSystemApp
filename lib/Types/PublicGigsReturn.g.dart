// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PublicGigsReturn.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Publicgigsreturn _$PublicgigsreturnFromJson(Map<String, dynamic> json) =>
    Publicgigsreturn(
      gigs: (json['gigs'] as List<dynamic>)
          .map((e) => Gigs.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: Gigpagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
      filters: Gigfilters.fromJson(json['filters'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PublicgigsreturnToJson(Publicgigsreturn instance) =>
    <String, dynamic>{
      'gigs': instance.gigs.map((e) => e.toJson()).toList(),
      'pagination': instance.pagination.toJson(),
      'filters': instance.filters.toJson(),
    };
