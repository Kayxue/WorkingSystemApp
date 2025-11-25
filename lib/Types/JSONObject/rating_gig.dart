import 'package:json_annotation/json_annotation.dart';

part 'rating_gig.g.dart';

@JsonSerializable(explicitToJson: true)
class RatingGig {
  String gigId;
  String title;
  DateTime startDate;
  DateTime endDate;

  RatingGig({
    required this.gigId,
    required this.title,
    required this.startDate,
    required this.endDate,
  });

  factory RatingGig.fromJson(Map<String, dynamic> json) =>
      _$RatingGigFromJson(json);
  Map<String, dynamic> toJson() => _$RatingGigToJson(this);
}
