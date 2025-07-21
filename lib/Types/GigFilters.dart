import 'package:json_annotation/json_annotation.dart';
part 'GigFilters.g.dart';

@JsonSerializable(explicitToJson: true)
class Gigfilters {
  String? city;
  String? district;
  int? minRate;
  int? maxRate;
  DateTime dateStart;
  DateTime? dateEnd;

  Gigfilters({
    this.city,
    this.district,
    this.minRate,
    this.maxRate,
    required this.dateStart,
    this.dateEnd,
  });
  factory Gigfilters.fromJson(Map<String, dynamic> json) => _$GigfiltersFromJson(json);
  Map<String, dynamic> toJson() => _$GigfiltersToJson(this);
}