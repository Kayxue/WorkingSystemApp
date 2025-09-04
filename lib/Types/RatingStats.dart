import 'package:json_annotation/json_annotation.dart';

part 'RatingStats.g.dart';

@JsonSerializable(explicitToJson: true)
class RatingStats {
  double averageRating;
  int totalRatings;

  RatingStats({required this.averageRating, required this.totalRatings});

  factory RatingStats.fromJson(Map<String, dynamic> json) =>
      _$RatingStatsFromJson(json);

  Map<String, dynamic> toJson() => _$RatingStatsToJson(this);
}
