import 'package:project_01/data/repositories/message_repository.dart';
import 'package:project_01/domain/entities/message.dart';

class SendMessage {
  final MessageRepository messageRepository;

  SendMessage(this.messageRepository);

  Future<void> call(String roomId, String username, String text) async {
    await messageRepository.sendMessage(roomId, username, text);
  }
}
