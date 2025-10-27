import 'package:json_annotation/json_annotation.dart';

part 'CurrentApplication.g.dart';

@JsonSerializable()
class CurrentApplication {
  String applicationId;
  String gigId;
  String title;
  String dateStart;
  String dateEnd;
  String timeStart;
  String timeEnd;
  String status;

  CurrentApplication({
    required this.applicationId,
    required this.gigId,
    required this.title,
    required this.dateStart,
    required this.dateEnd,
    required this.timeStart,
    required this.timeEnd,
    required this.status,
  });
  
  factory CurrentApplication.fromJson(Map<String, dynamic> json) =>
      _$CurrentApplicationFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentApplicationToJson(this);
}