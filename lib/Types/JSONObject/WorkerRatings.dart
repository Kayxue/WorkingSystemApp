import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/WorkerRatingGig.dart';
import 'package:working_system_app/Types/JSONObject/WorkerReviewEmployer.dart';

part 'WorkerRatings.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkerRatings {
  String ratingId;
  WorkerReviewEmployer employer;
  WorkerRatingGig gig;
  double ratingValue;
  String comment;
  DateTime createdAt;

  WorkerRatings({
    required this.ratingId,
    required this.employer,
    required this.gig,
    required this.ratingValue,
    required this.comment,
    required this.createdAt,
  });

  factory WorkerRatings.fromJson(Map<String, dynamic> json) =>
      _$WorkerRatingsFromJson(json);
  Map<String, dynamic> toJson() => _$WorkerRatingsToJson(this);
}
