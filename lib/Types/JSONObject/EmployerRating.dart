import 'package:json_annotation/json_annotation.dart';

part 'EmployerRating.g.dart';

@JsonSerializable(explicitToJson: true)
class EmployerRating{
  String ratingId;
  String name;
  double ratingValue;
  String? comment;
  DateTime createdAt;

  EmployerRating({
    required this.ratingId,
    required this.name,
    required this.ratingValue,
    required this.comment,
    required this.createdAt,
  });

  factory EmployerRating.fromJson(Map<String, dynamic> json) =>
      _$EmployerRatingFromJson(json);

  Map<String, dynamic> toJson() => _$EmployerRatingToJson(this);
}