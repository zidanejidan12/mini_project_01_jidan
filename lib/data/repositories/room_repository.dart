import 'package:http/http.dart' as http;
import 'dart:convert';

class RoomRepository {
  Future<List<String>> getRooms(String username) async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8080/api/user/$username'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['data'] != null) {
        return List<String>.from(data['data']['rooms']);
      } else {
        // handle the case when 'data' is null
        return [];
      }
    } else {
      throw Exception('Failed to load rooms');
    }
  }
}
