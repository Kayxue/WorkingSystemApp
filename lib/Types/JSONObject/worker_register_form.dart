import 'package:json_annotation/json_annotation.dart';

part 'worker_register_form.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkerRegisterForm {
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  String phoneNumber = '';
  String highestEducation = '';
  String? schoolName;
  String? major;
  String studyStatus = "就讀中";
  List<String> certificates = [];
  List<String> jobExperience = [];

  WorkerRegisterForm();

  factory WorkerRegisterForm.fromJson(Map<String, dynamic> json) =>
      _$WorkerRegisterFormFromJson(json);
  Map<String, dynamic> toJson() => _$WorkerRegisterFormToJson(this);
}
