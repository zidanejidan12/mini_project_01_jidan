import 'package:project_01/data/datasources/chat_api.dart';
import 'package:project_01/domain/entities/message.dart';

class MessageRepository {
  final ChatApi chatApi;

  MessageRepository({required this.chatApi});

  Future<List<Message>> getRoomMessages(String roomId) async {
    List<Map<String, dynamic>> messagesData =
        await chatApi.getRoomMessages(roomId);
    return messagesData
        .map((messageData) => Message.fromMap(messageData))
        .toList()
        .cast<Message>();
  }

  Future<bool> sendMessage(String roomId, String username, String text) async {
    return await chatApi.sendMessage(roomId, username, text);
  }
}
