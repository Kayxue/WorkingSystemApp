import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/ReviewEmployer.dart';

part 'WorkerReview.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkerReview {
  String gigId;
  String title;
  DateTime startDate;
  DateTime endDate;
  ReviewEmployer employer;

  WorkerReview({
    required this.gigId,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.employer,
  });

  factory WorkerReview.fromJson(Map<String, dynamic> json) =>
      _$WorkerReviewFromJson(json);
  Map<String, dynamic> toJson() => _$WorkerReviewToJson(this);
}
