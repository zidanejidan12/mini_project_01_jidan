import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                  ),
                  onFieldSubmitted: (_) {
                    _login(context);
                  },
                ),
              ),
              ElevatedButton(
                child: const Text('Login'),
                onPressed: () {
                  _login(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => HomePage(username: usernameController.text)),
    );
  }
}

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({Key? key, required this.username}) : super(key: key);

  get roomId => null;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<String> rooms = [];
  Map<String, List<Map<String, dynamic>>> roomMessages = {};

  @override
  void initState() {
    super.initState();
    _getRooms();
  }

  _getRooms() async {
    final response = await http
        .get(Uri.parse('http://127.0.0.1:8080/api/user/${widget.username}'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['data'] != null) {
        setState(() {
          rooms = List<String>.from(data['data']['rooms']);
          _getRoomMessages();
        });
      } else {
        // handle the case when 'data' is null
        rooms = [];
      }
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  _getRoomMessages() async {
    for (var roomId in rooms) {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:8080/api/chat/$roomId'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() {
            var messages =
                List<Map<String, dynamic>>.from(data['data']['messages']);
            messages.sort((a, b) => (b['timestamp'] is int
                    ? b['timestamp']
                    : int.parse(b['timestamp']))
                .compareTo(a['timestamp'] is int
                    ? a['timestamp']
                    : int.parse(a['timestamp'])));
            roomMessages[roomId] = messages;
          });
        }
      } else {
        throw Exception('Failed to load messages for room $roomId');
      }
    }
  }

  _createNewRoom(String from, String to) async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/room'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'from': from,
        'to': to,
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['data'] != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomPage(
              roomId: data['data']['id'],
              username: widget.username,
            ),
          ),
        );
      } else {
        print('Response data is null');
      }
    } else {
      throw Exception('Failed to create room');
    }
  }

  @override
  // In HomePageState
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final TextEditingController controller = TextEditingController();
          return showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Enter username'),
                content: TextField(
                  controller: controller,
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Send'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _createNewRoom(
                          widget.username,
                          controller
                              .text); // ganti 'currentUser' dengan username pengguna saat ini
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.message),
      ),
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          String roomId = rooms[index];
          var lastMessage;
          if (roomMessages[roomId] != null &&
              roomMessages[roomId]!.isNotEmpty) {
            lastMessage = roomMessages[roomId]![0];
          } else {
            lastMessage = null;
          }
          return ListTile(
            leading: CircleAvatar(
              child: Text(lastMessage != null && lastMessage['username'] != null
                  ? lastMessage['username'][0].toUpperCase()
                  : ''),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    lastMessage != null
                        ? '${lastMessage['username']}'
                        : 'No messages',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  lastMessage != null ? '${lastMessage['timestamp']}' : '',
                ),
              ],
            ),
            subtitle: Text(
              lastMessage != null ? '${lastMessage['text']}' : '',
            ),
            onTap: () {
              // Navigate to the chatroom page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoomPage(
                    roomId: roomId,
                    username: widget.username,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ChatRoomPage extends StatefulWidget {
  final String roomId;
  final String username;

  const ChatRoomPage({Key? key, required this.roomId, required this.username})
      : super(key: key);

  @override
  ChatRoomPageState createState() => ChatRoomPageState();
}

class ChatRoomPageState extends State<ChatRoomPage> {
  List<Map<String, dynamic>> messages = [];
  final messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getMessages();
  }

  _getMessages() async {
    final response = await http
        .get(Uri.parse('http://127.0.0.1:8080/api/chat/${widget.roomId}'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['data'] != null) {
        setState(() {
          messages = List<Map<String, dynamic>>.from(data['data']['messages']);
          for (var message in messages) {
            if (message['timestamp'] is String) {
              message['timestamp'] = int.parse(message['timestamp']);
            }
          }
          // Sort messages in descending order of timestamp
          messages.sort((b, a) => b['timestamp'].compareTo(a['timestamp']));
        });
      } else {
        // handle the case when 'data' is null
        messages = [];
      }
    } else {
      throw Exception('Failed to load messages for room ${widget.roomId}');
    }
  }

  _sendMessage() async {
    if (messageController.text.isNotEmpty) {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8080/api/chat'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'id': widget.roomId,
          'username': widget.username,
          'text': messageController.text,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['data'] == true) {
          setState(() {
            if (messages != null) {
              messages.add({
                'username': widget.username,
                'text': messageController.text,
                'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
              });
            }
            messageController.clear();
          });
        } else {
          // handle the case when 'data' is not true
        }
      } else {
        throw Exception('Failed to send message');
      }
    } else {
      // handle the case when the message is empty
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please enter a message.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room ${widget.username}'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];
                bool isCurrentUser = message['username'] == widget.username;
                return Container(
                  margin: const EdgeInsets.symmetric(
                      vertical:
                          5), // Adjust vertical margin to make the box smaller
                  child: Row(
                    mainAxisAlignment: isCurrentUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!isCurrentUser && message['username'] != null)
                        CircleAvatar(
                          child: Text(message['username'][0].toUpperCase()),
                        ),
                      SizedBox(
                          width:
                              10), // Add a gap between CircleAvatar and message text box
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(
                              8), // Adjust padding to make the box smaller
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? Colors.blue[200]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['username'] ?? 'Unknown',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text('${message['text']}'),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text('${message['timestamp']}',
                                    style: TextStyle(fontSize: 10)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isCurrentUser && message['username'] != null)
                        CircleAvatar(
                          child: Text(message['username'][0].toUpperCase()),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
