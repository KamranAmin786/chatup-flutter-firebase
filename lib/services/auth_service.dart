import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  static const _avatarColors = [
    0xFF00A884, 0xFF53BDEB, 0xFFFF7A59, 0xFFA78BFA, 0xFFF59E0B, 0xFFEC4899,
  ];

  Stream<User?> get authChanges => _auth.authStateChanges();

  String get uid => _auth.currentUser!.uid;

  Future<void> signUp(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = AppUser(
      uid: cred.user!.uid,
      name: name,
      email: email,
      color: _avatarColors[Random().nextInt(_avatarColors.length)],
      online: true,
    );
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    await setOnline(true);
  }

  Future<void> signOut() async {
    await setOnline(false);
    await _auth.signOut();
  }

  // online dot + "last seen" in the chat header
  Future<void> setOnline(bool online) async {
    if (_auth.currentUser == null) return;
    await _db.collection('users').doc(uid).update({
      'online': online,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }
}
