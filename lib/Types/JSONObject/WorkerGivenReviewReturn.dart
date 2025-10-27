import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/Pagination.dart';
import 'package:working_system_app/Types/JSONObject/WorkerRatings.dart';

part 'WorkerGivenReviewReturn.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkerGivenReviewReturn {
  List<WorkerRatings> myRatings;
  Pagination pagination;

  WorkerGivenReviewReturn({
    required this.myRatings,
    required this.pagination,
  });

  factory WorkerGivenReviewReturn.fromJson(Map<String, dynamic> json) =>
      _$WorkerGivenReviewReturnFromJson(json);
  Map<String, dynamic> toJson() => _$WorkerGivenReviewReturnToJson(this);
}
