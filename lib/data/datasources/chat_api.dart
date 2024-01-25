import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatApi {
  Future<List<String>> getRooms(String username) async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8080/api/user/$username'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['data'] != null) {
        return List<String>.from(data['data']['rooms']);
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  Future<List<Map<String, dynamic>>> getRoomMessages(String roomId) async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8080/api/chat/$roomId'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['data'] != null) {
        return List<Map<String, dynamic>>.from(data['data']['messages']);
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load messages for room $roomId');
    }
  }

  Future<bool> sendMessage(String roomId, String username, String text) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8080/api/chat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'id': roomId,
        'username': username,
        'text': text,
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['data'] == true;
    } else {
      throw Exception('Failed to send message');
    }
  }
}
