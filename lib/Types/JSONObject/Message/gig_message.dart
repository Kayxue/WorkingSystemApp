import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/Message/message.dart';
import 'package:working_system_app/Types/JSONObject/Message/gig_return_for_message.dart';

part 'gig_message.g.dart';

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
