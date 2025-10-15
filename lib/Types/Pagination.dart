import 'package:json_annotation/json_annotation.dart';

part 'Pagination.g.dart';

@JsonSerializable(explicitToJson: true)
class Pagination {
  int limit;
  int page;
  bool hasMore;
  int returned;

  Pagination({
    required this.limit,
    required this.page,
    required this.hasMore,
    required this.returned,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}
