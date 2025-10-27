import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/Conflict/CurrentApplication.dart';
import 'package:working_system_app/Types/JSONObject/Conflict/ConfirmedGig.dart';
import 'package:working_system_app/Types/JSONObject/Conflict/PendingApplication.dart';
import 'package:working_system_app/Types/JSONObject/ApplicationPagination.dart';

part 'ConflictReturn.g.dart';

@JsonSerializable(explicitToJson: true)
class ConflictReturn {
  CurrentApplication application;
  List<ConfirmedGig> confirmedGigConflicts;
  List<PendingApplication> pendingApplicationConflicts;
  ApplicationPagination pagination;

  ConflictReturn({
    required this.application,
    this.confirmedGigConflicts = const [],
    this.pendingApplicationConflicts = const [],
    required this.pagination,
  });

  factory ConflictReturn.fromJson(Map<String, dynamic> json) =>
      _$ConflictReturnFromJson(json);
  
  Map<String, dynamic> toJson() => _$ConflictReturnToJson(this);
}