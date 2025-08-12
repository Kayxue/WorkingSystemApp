import 'package:freezed_annotation/freezed_annotation.dart';

part 'DescriptionType.freezed.dart';
part 'DescriptionType.g.dart';

@freezed
sealed class DescriptionType with _$DescriptionType {
  const factory DescriptionType.string(String value) = _String;
  const factory DescriptionType.map(Map<String, String> value) = _Map;

  factory DescriptionType.fromJson(Map<String, dynamic> json) =>
      _$DescriptionTypeFromJson(json);
}