import 'package:json_annotation/json_annotation.dart';

part 'GigPagination.g.dart';

@JsonSerializable(explicitToJson: true)
class GigPagination {
  int limit;
  int page;
  bool hasMore;
  int returned;

  GigPagination({
    required this.limit,
    required this.page,
    required this.hasMore,
    required this.returned,
  });

  factory GigPagination.fromJson(Map<String, dynamic> json) =>
      _$GigPaginationFromJson(json);

  Map<String, dynamic> toJson() => _$GigPaginationToJson(this);
}
