import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String text;
  final String? imageUrl;
  final DateTime time;
  final bool read;
  final bool deleted;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    this.imageUrl,
    required this.time,
    this.read = false,
    this.deleted = false,
  });

  factory Message.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Message(
      id: doc.id,
      senderId: data['senderId'],
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      // serverTimestamp is null until the server writes it
      time: (data['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] ?? false,
      deleted: data['deleted'] ?? false,
    );
  }
}
