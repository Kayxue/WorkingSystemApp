import 'package:json_annotation/json_annotation.dart';
import 'Application.dart';
import 'ApplicationPagination.dart';

part 'UserApplication.g.dart';

@JsonSerializable(explicitToJson: true)
class UserApplication {
  List<Application> applications;
  ApplicationPagination pagination;

  UserApplication({
    required this.applications,
    required this.pagination,
  });

  factory UserApplication.fromJson(Map<String, dynamic> json) =>
      _$UserApplicationFromJson(json);

  Map<String, dynamic> toJson() => _$UserApplicationToJson(this);
}