import 'package:json_annotation/json_annotation.dart';

part 'GigPagination.g.dart';

@JsonSerializable(explicitToJson: true)
class Gigpagination {
  int limit;
  int page;
  bool hasMore;
  int returned;

  Gigpagination({
    required this.limit,
    required this.page,
    required this.hasMore,
    required this.returned,
  });

  factory Gigpagination.fromJson(Map<String, dynamic> json) =>
      _$GigpaginationFromJson(json);

  Map<String, dynamic> toJson() => _$GigpaginationToJson(this);
}
