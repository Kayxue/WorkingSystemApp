import 'package:json_annotation/json_annotation.dart';

part 'gig_filters.g.dart';

@JsonSerializable(explicitToJson: true)
class GigFilters {
  String? city;
  String? district;
  int? minRate;
  int? maxRate;
  DateTime? dateStart;

  GigFilters({
    this.city,
    this.district,
    this.minRate,
    this.maxRate,
    this.dateStart,
  });

  factory GigFilters.fromJson(Map<String, dynamic> json) =>
      _$GigFiltersFromJson(json);

  Map<String, dynamic> toJson() => _$GigFiltersToJson(this);
}
