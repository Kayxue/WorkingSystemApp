import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/pagination.dart';
import 'package:working_system_app/Types/JSONObject/ratings.dart';

part 'given_review_return.g.dart';

@JsonSerializable(explicitToJson: true)
class GivenReviewReturn {
  List<Ratings> ratings;
  Pagination pagination;

  GivenReviewReturn({required this.ratings, required this.pagination});

  factory GivenReviewReturn.fromJson(Map<String, dynamic> json) =>
      _$GivenReviewReturnFromJson(json);
  Map<String, dynamic> toJson() => _$GivenReviewReturnToJson(this);
}
