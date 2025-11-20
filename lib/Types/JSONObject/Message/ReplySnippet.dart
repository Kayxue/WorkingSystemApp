import 'package:json_annotation/json_annotation.dart';

part 'ReplySnippet.g.dart';

@JsonSerializable()
class ReplySnippet {
  final String messagesId;
  final String content;
  final DateTime createdAt;

  ReplySnippet({
    required this.messagesId,
    required this.content,
    required this.createdAt,
  });

  factory ReplySnippet.fromJson(Map<String, dynamic> json) =>
      _$ReplySnippetFromJson(json);

  Map<String, dynamic> toJson() => _$ReplySnippetToJson(this);
}
