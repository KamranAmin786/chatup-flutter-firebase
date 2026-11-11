import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/app_user.dart';
import '../models/chat.dart';
import '../models/message.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  String get myId => FirebaseAuth.instance.currentUser!.uid;

  // the same two people always get the same chat id
  String chatId(String otherId) {
    final ids = [myId, otherId]..sort();
    return ids.join('_');
  }

  Stream<AppUser> userStream(String uid) => _db
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => AppUser.fromDoc(doc));

  Stream<List<AppUser>> allUsers() => _db
      .collection('users')
      .orderBy('name')
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => AppUser.fromDoc(doc))
          .where((user) => user.uid != myId)
          .toList());

  // sorted here in the app, so Firestore needs no extra index
  Stream<List<Chat>> myChats() => _db
      .collection('chats')
      .where('members', arrayContains: myId)
      .snapshots()
      .map((snap) {
        final chats = snap.docs.map((doc) => Chat.fromDoc(doc)).toList();
        chats.sort((a, b) => (b.lastTime ?? DateTime.now())
            .compareTo(a.lastTime ?? DateTime.now()));
        return chats;
      });

  Stream<List<Message>> messages(String chatId) => _db
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('time', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => Message.fromDoc(doc)).toList());

  Stream<Chat?> chatStream(String chatId) =>
      _db.collection('chats').doc(chatId).snapshots().map(
            (doc) => doc.exists ? Chat.fromDoc(doc) : null,
          );

  Future<void> sendMessage(String otherId, {String text = '', String? imageUrl}) async {
    final id = chatId(otherId);
    final chatRef = _db.collection('chats').doc(id);
    final batch = _db.batch();

    batch.set(chatRef.collection('messages').doc(), {
      'senderId': myId,
      'text': text,
      'imageUrl': imageUrl,
      'time': FieldValue.serverTimestamp(),
      'read': false,
    });

    batch.set(
      chatRef,
      {
        'members': [myId, otherId],
        'lastMessage': imageUrl != null ? '📷 Photo' : text,
        'lastSender': myId,
        'lastTime': FieldValue.serverTimestamp(),
        'unread': {otherId: FieldValue.increment(1)},
        'typing': {myId: false},
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<void> sendImage(String otherId, Uint8List bytes) async {
    final path = 'chats/${chatId(otherId)}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref(path);
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    final url = await ref.getDownloadURL();
    await sendMessage(otherId, imageUrl: url);
  }

  // blue ticks: mark the other person's messages as read
  Future<void> markAsRead(String otherId) async {
    final id = chatId(otherId);
    final chatRef = _db.collection('chats').doc(id);
    final unread = await chatRef
        .collection('messages')
        .where('senderId', isEqualTo: otherId)
        .where('read', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'read': true});
    }
    batch.set(chatRef, {'unread': {myId: 0}}, SetOptions(merge: true));
    await batch.commit();
  }

  // "delete for everyone": keep the message, remove its content
  Future<void> deleteMessage(String otherId, String messageId) async {
    await _db
        .collection('chats')
        .doc(chatId(otherId))
        .collection('messages')
        .doc(messageId)
        .update({'text': '', 'imageUrl': null, 'deleted': true});
  }

  Future<void> updateProfile(String name, String about) async {
    await _db.collection('users').doc(myId).update({'name': name, 'about': about});
  }

  Future<void> setTyping(String otherId, bool typing) async {
    await _db.collection('chats').doc(chatId(otherId)).set(
      {'typing': {myId: typing}},
      SetOptions(merge: true),
    );
  }
}
