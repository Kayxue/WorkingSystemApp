import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/EmployerRating.dart';
import 'package:working_system_app/Types/JSONObject/Pagination.dart';

part 'EmployerReviewReturn.g.dart';

@JsonSerializable(explicitToJson: true)
class EmployerReviewReturn{
  List<EmployerRating> ratings;
  Pagination pagination;

  EmployerReviewReturn({
    required this.ratings,
    required this.pagination,
  });

  factory EmployerReviewReturn.fromJson(Map<String, dynamic> json) =>
      _$EmployerReviewReturnFromJson(json);

  Map<String, dynamic> toJson() => _$EmployerReviewReturnToJson(this);
}