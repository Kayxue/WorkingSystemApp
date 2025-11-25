import 'package:json_annotation/json_annotation.dart';

part 'gigs.g.dart';

@JsonSerializable(explicitToJson: true)
class Gigs {
  DateTime updatedAt;
  String gigId;
  String title;
  int hourlyRate;
  String city;
  String district;

  Gigs({
    required this.updatedAt,
    required this.gigId,
    required this.title,
    required this.hourlyRate,
    required this.city,
    required this.district,
  });

  factory Gigs.fromJson(Map<String, dynamic> json) => _$GigsFromJson(json);

  Map<String, dynamic> toJson() => _$GigsToJson(this);
}
