import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/EmployerPhoto.dart';

part 'ApplicationGig.g.dart';

@JsonSerializable(explicitToJson: true)
class ApplicationGig {
  String gigId;
  String title;
  DateTime dateStart;
  DateTime dateEnd;
  String timeStart;
  String timeEnd;
  Map<String,dynamic> employer;

  ApplicationGig({
    required this.gigId,
    required this.title,
    required this.dateStart,
    required this.dateEnd,
    required this.timeStart,
    required this.timeEnd,
    required this.employer
  });

  factory ApplicationGig.fromJson(Map<String, dynamic> json) =>
      _$ApplicationGigFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationGigToJson(this);
}