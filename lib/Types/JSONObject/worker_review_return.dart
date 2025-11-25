import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/pagination.dart';
import 'package:working_system_app/Types/JSONObject/worker_review.dart';

part 'worker_review_return.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkerReviewReturn {
  List<WorkerReview> ratableGigs;
  Pagination pagination;

  WorkerReviewReturn({required this.ratableGigs, required this.pagination});

  factory WorkerReviewReturn.fromJson(Map<String, dynamic> json) =>
      _$WorkerReviewReturnFromJson(json);
  Map<String, dynamic> toJson() => _$WorkerReviewReturnToJson(this);
}
