import 'package:json_annotation/json_annotation.dart';

part 'environment_photo.g.dart';

@JsonSerializable(explicitToJson: true)
class EnvironmentPhoto {
  String url;
  String originalName;
  String type;
  String filename;

  EnvironmentPhoto({
    required this.url,
    required this.originalName,
    required this.type,
    required this.filename,
  });

  factory EnvironmentPhoto.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentPhotoFromJson(json);

  Map<String, dynamic> toJson() => _$EnvironmentPhotoToJson(this);
}
