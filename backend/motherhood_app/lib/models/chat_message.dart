class ChatMessage {
  final String message;
  final String senderName;
  final DateTime timestamp;
  final bool isMine;

  ChatMessage({
    required this.message,
    required this.senderName,
    required this.timestamp,
    required this.isMine,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUsername) {
    return ChatMessage(
      message: json['message'],
      senderName: json['sender_name'] ?? 'Unknown',
      timestamp: DateTime.parse(json['timestamp']),
      isMine: json['sender_name'] == currentUsername,
    );
  }
}
