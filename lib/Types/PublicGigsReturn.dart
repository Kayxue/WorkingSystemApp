import 'package:json_annotation/json_annotation.dart';
import 'GigFilters.dart';
import 'GigPagination.dart';
import 'Gigs.dart';

part 'PublicGigsReturn.g.dart';

@JsonSerializable(explicitToJson: true)
class Publicgigsreturn {
  List<Gigs> gigs;
  Gigpagination pagination;
  Gigfilters filters;

  Publicgigsreturn({
    required this.gigs,
    required this.pagination,
    required this.filters,
  });

  factory Publicgigsreturn.fromJson(Map<String, dynamic> json) =>
      _$PublicgigsreturnFromJson(json);

  Map<String, dynamic> toJson() => _$PublicgigsreturnToJson(this);
}
