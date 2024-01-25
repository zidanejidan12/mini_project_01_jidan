import 'package:project_01/domain/entities/message.dart';

class ChatRoom {
  final String roomId;
  final String username;
  final List<Message> messages;

  ChatRoom({
    required this.roomId,
    required this.username,
    required this.messages,
  });
}
