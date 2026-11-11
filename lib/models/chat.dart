import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final List<String> members;
  final String lastMessage;
  final String lastSender;
  final DateTime? lastTime;
  final Map<String, dynamic> unread;
  final Map<String, dynamic> typing;

  Chat({
    required this.id,
    required this.members,
    required this.lastMessage,
    required this.lastSender,
    this.lastTime,
    this.unread = const {},
    this.typing = const {},
  });

  factory Chat.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Chat(
      id: doc.id,
      members: List<String>.from(data['members'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastSender: data['lastSender'] ?? '',
      lastTime: (data['lastTime'] as Timestamp?)?.toDate(),
      unread: Map<String, dynamic>.from(data['unread'] ?? {}),
      typing: Map<String, dynamic>.from(data['typing'] ?? {}),
    );
  }

  String otherId(String myId) => members.firstWhere((m) => m != myId);

  int unreadFor(String uid) => (unread[uid] ?? 0) as int;

  bool isTyping(String uid) => typing[uid] == true;
}
