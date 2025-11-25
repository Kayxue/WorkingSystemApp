import 'package:json_annotation/json_annotation.dart';

part 'review_employer.g.dart';

@JsonSerializable(explicitToJson: true)
class ReviewEmployer {
  String employerId;
  String name;

  ReviewEmployer({required this.employerId, required this.name});

  factory ReviewEmployer.fromJson(Map<String, dynamic> json) =>
      _$ReviewEmployerFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewEmployerToJson(this);
}
