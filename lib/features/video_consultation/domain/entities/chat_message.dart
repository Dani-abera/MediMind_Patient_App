import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.senderName,
    required this.content,
    required this.sentAt,
    required this.isFromPatient,
  });

  final String id;
  final String senderName;
  final String content;
  final DateTime sentAt;
  final bool isFromPatient;

  @override
  List<Object?> get props => [id, senderName, content, sentAt, isFromPatient];
}
