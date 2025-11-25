import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/pagination.dart';
import 'application.dart';

part 'user_application.g.dart';

@JsonSerializable(explicitToJson: true)
class UserApplication {
  List<Application> applications;
  Pagination pagination;

  UserApplication({required this.applications, required this.pagination});

  factory UserApplication.fromJson(Map<String, dynamic> json) =>
      _$UserApplicationFromJson(json);

  Map<String, dynamic> toJson() => _$UserApplicationToJson(this);
}
