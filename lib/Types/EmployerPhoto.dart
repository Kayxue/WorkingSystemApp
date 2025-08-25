import 'package:json_annotation/json_annotation.dart';

part 'EmployerPhoto.g.dart';

@JsonSerializable(explicitToJson: true)
class EmployerPhoto {
  String url;
  String originalName;
  String type;
  
  EmployerPhoto({
    required this.url,
    required this.originalName,
    required this.type,
  });

  factory EmployerPhoto.fromJson(Map<String, dynamic> json) =>
      _$EmployerPhotoFromJson(json);
  Map<String, dynamic> toJson() => _$EmployerPhotoToJson(this);
}