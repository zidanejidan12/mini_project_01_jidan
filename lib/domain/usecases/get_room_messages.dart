import 'package:project_01/data/repositories/message_repository.dart';
import 'package:project_01/domain/entities/message.dart';

class GetRoomMessages {
  final MessageRepository messageRepository;

  GetRoomMessages(this.messageRepository);

  Future<List<Message>> call(String roomId) async {
    return await messageRepository.getRoomMessages(roomId);
  }
}
