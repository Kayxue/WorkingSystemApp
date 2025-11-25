import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/rating_gig.dart';
import 'package:working_system_app/Types/JSONObject/review_employer.dart';

part 'ratings.g.dart';

@JsonSerializable(explicitToJson: true)
class Ratings {
  String ratingId;
  ReviewEmployer employer;
  RatingGig gig;
  double ratingValue;
  String? comment;
  DateTime createdAt;

  Ratings({
    required this.ratingId,
    required this.employer,
    required this.gig,
    required this.ratingValue,
    required this.comment,
    required this.createdAt,
  });

  factory Ratings.fromJson(Map<String, dynamic> json) =>
      _$RatingsFromJson(json);
  Map<String, dynamic> toJson() => _$RatingsToJson(this);
}
