import 'package:json_annotation/json_annotation.dart';

part 'requirements.g.dart';

@JsonSerializable(explicitToJson: true)
class Requirements {
  List<String> skills;
  String experience;

  Requirements({required this.skills, required this.experience});

  factory Requirements.fromJson(Map<String, dynamic> json) =>
      _$RequirementsFromJson(json);

  Map<String, dynamic> toJson() => _$RequirementsToJson(this);
}
