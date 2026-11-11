import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String about;
  final int color;
  final bool online;
  final DateTime? lastSeen;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.about = 'Hey there! I am using ChatUp.',
    required this.color,
    this.online = false,
    this.lastSeen,
  });

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      about: data['about'] ?? '',
      color: data['color'] ?? 0xFF00A884,
      online: data['online'] ?? false,
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'about': about,
        'color': color,
        'online': online,
        'lastSeen': FieldValue.serverTimestamp(),
      };
}
