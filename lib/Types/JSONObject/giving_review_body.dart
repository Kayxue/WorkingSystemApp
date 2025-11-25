import 'package:json_annotation/json_annotation.dart';

part 'giving_review_body.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class GivingReviewBody {
  int ratingValue;
  String? comment;

  GivingReviewBody({required this.ratingValue, required this.comment});

  factory GivingReviewBody.fromJson(Map<String, dynamic> json) =>
      _$GivingReviewBodyFromJson(json);

  Map<String, dynamic> toJson() => _$GivingReviewBodyToJson(this);
}
