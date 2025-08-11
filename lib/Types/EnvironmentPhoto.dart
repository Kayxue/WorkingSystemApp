import 'package:json_annotation/json_annotation.dart';
part 'EnvironmentPhoto.g.dart';

@JsonSerializable(explicitToJson: true)
class Environmentphoto {
  String url;
  String originalName;
  String type;
  String filename;

  Environmentphoto({
    required this.url,
    required this.originalName,
    required this.type,
    required this.filename,
  });

  factory Environmentphoto.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentphotoFromJson(json);
  Map<String, dynamic> toJson() => _$EnvironmentphotoToJson(this);
}