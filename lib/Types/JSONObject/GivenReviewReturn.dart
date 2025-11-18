import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/Pagination.dart';
import 'package:working_system_app/Types/JSONObject/Ratings.dart';

part 'GivenReviewReturn.g.dart';

@JsonSerializable(explicitToJson: true)
class GivenReviewReturn {
  List<Ratings> ratings;
  Pagination pagination;

  GivenReviewReturn({required this.ratings, required this.pagination});

  factory GivenReviewReturn.fromJson(Map<String, dynamic> json) =>
      _$GivenReviewReturnFromJson(json);
  Map<String, dynamic> toJson() => _$GivenReviewReturnToJson(this);
}
