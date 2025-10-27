import 'package:json_annotation/json_annotation.dart';

part 'GivingReviewBody.g.dart';

@JsonSerializable(explicitToJson: true)
class GivingReviewBody {
  int ratingValue;
  String? comment;

  GivingReviewBody({required this.ratingValue, required this.comment});

  factory GivingReviewBody.fromJson(Map<String, dynamic> json) =>
      _$GivingReviewBodyFromJson(json);

  Map<String, dynamic> toJson() => _$GivingReviewBodyToJson(this);
}
