import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/ProfilePhoto.dart';

part 'WorkerReviewEmployer.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkerReviewEmployer {
  String employerId;
  String name;

  WorkerReviewEmployer({required this.employerId, required this.name});

  factory WorkerReviewEmployer.fromJson(Map<String, dynamic> json) =>
      _$WorkerReviewEmployerFromJson(json);
  Map<String, dynamic> toJson() => _$WorkerReviewEmployerToJson(this);
}
