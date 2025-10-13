import 'package:json_annotation/json_annotation.dart';

part 'ApplicationPagination.g.dart';

@JsonSerializable()
class ApplicationPagination {
  int limit;
  int offset;
  bool hasMore;
  int returned;

  ApplicationPagination({
    required this.limit,
    required this.offset,
    required this.hasMore,
    required this.returned,
  });

  factory ApplicationPagination.fromJson(Map<String, dynamic> json) =>
      _$ApplicationPaginationFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationPaginationToJson(this);
}