class Message {
  final String username;
  final String text;
  final int timestamp;

  Message({
    required this.username,
    required this.text,
    required this.timestamp,
  });

  // Assuming your messageData map contains 'username', 'text', and 'timestamp'
  factory Message.fromMap(Map<String, dynamic> messageData) {
    return Message(
      username: messageData['username'],
      text: messageData['text'],
      timestamp: messageData['timestamp'],
    );
  }
}
