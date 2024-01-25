import 'package:project_01/data/repositories/room_repository.dart';

class GetRooms {
  final RoomRepository roomRepository;

  GetRooms(this.roomRepository);

  Future<List<String>> call(String username) async {
    return await roomRepository.getRooms(username);
  }
}
