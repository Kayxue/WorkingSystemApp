import 'package:json_annotation/json_annotation.dart';

part 'WorkerRatingGig.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkerRatingGig {
  String gigId;
  String title;
  DateTime startDate;
  DateTime endDate;

  WorkerRatingGig({
    required this.gigId,
    required this.title,
    required this.startDate,
    required this.endDate,
  });

  factory WorkerRatingGig.fromJson(Map<String, dynamic> json) =>
      _$WorkerRatingGigFromJson(json);
  Map<String, dynamic> toJson() => _$WorkerRatingGigToJson(this);
}
