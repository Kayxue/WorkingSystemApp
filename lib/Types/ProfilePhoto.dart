import 'package:json_annotation/json_annotation.dart';

part 'ProfilePhoto.g.dart';

@JsonSerializable(explicitToJson: true)
class ProfilePhoto {
  String url;
  String originalName;
  String type;
  
  ProfilePhoto({
    required this.url,
    required this.originalName,
    required this.type,
  });

  factory ProfilePhoto.fromJson(Map<String, dynamic> json) =>
      _$ProfilePhotoFromJson(json);
  Map<String, dynamic> toJson() => _$ProfilePhotoToJson(this);
}