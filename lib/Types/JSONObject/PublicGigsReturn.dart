import 'package:json_annotation/json_annotation.dart';
import 'GigFilters.dart';
import 'Pagination.dart';
import 'Gigs.dart';

part 'PublicGigsReturn.g.dart';

@JsonSerializable(explicitToJson: true)
class PublicGigsReturn {
  List<Gigs> gigs;
  Pagination pagination;
  GigFilters filters;

  PublicGigsReturn({
    required this.gigs,
    required this.pagination,
    required this.filters,
  });

  factory PublicGigsReturn.fromJson(Map<String, dynamic> json) =>
      _$PublicGigsReturnFromJson(json);

  Map<String, dynamic> toJson() => _$PublicGigsReturnToJson(this);
}
