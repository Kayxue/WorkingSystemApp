import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/Message/Message.dart';
import 'package:working_system_app/Types/JSONObject/Message/GigReturnForMessage.dart';

part 'GigMessage.g.dart';

@JsonSerializable(explicitToJson: true)
class GigMessage {
  final Message message;
  final GigReturnForMessage gig;
  final String employerName;

  GigMessage({
    required this.message,
    required this.gig,
    required this.employerName,
  });

  factory GigMessage.fromJson(Map<String, dynamic> json) => _$GigMessageFromJson(json);
  Map<String, dynamic> toJson() => _$GigMessageToJson(this);
}
