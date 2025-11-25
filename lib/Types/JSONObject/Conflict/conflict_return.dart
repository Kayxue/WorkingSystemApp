import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/Conflict/current_application.dart';
import 'package:working_system_app/Types/JSONObject/Conflict/confirmed_gig.dart';
import 'package:working_system_app/Types/JSONObject/Conflict/pending_application.dart';
import 'package:working_system_app/Types/JSONObject/pagination.dart';

part 'conflict_return.g.dart';

@JsonSerializable(explicitToJson: true)
class ConflictReturn {
  CurrentApplication application;
  List<ConfirmedGig> confirmedGigConflicts;
  List<PendingApplication> pendingApplicationConflicts;
  Pagination pagination;

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
