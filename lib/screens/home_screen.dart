import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/chat.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../theme.dart';
import '../widgets/chat_tile.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'users_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _auth = AuthService();
  final _chats = ChatService();
  bool _unreadOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _auth.setOnline(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // app goes to the background -> offline, comes back -> online
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _auth.setOnline(state == AppLifecycleState.resumed);
  }

  void _openChat(AppUser user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(otherId: user.uid)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ChatUp',
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.camera_alt_outlined)),
          PopupMenuButton<String>(
            color: AppColors.surfaceLight,
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              } else {
                _auth.signOut();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'profile', child: Text('Profile')),
              const PopupMenuItem(value: 'logout', child: Text('Log out')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                _filterChip('All', !_unreadOnly, () => setState(() => _unreadOnly = false)),
                const SizedBox(width: 8),
                _filterChip('Unread', _unreadOnly, () => setState(() => _unreadOnly = true)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Chat>>(
              stream: _chats.myChats(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var chats = snapshot.data!;
                if (_unreadOnly) {
                  chats = chats.where((c) => c.unreadFor(_chats.myId) > 0).toList();
                }
                if (chats.isEmpty) {
                  return const Center(
                    child: Text(
                      'No chats yet.\nTap the button below to start one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, i) {
                    final chat = chats[i];
                    return StreamBuilder<AppUser>(
                      stream: _chats.userStream(chat.otherId(_chats.myId)),
                      builder: (context, userSnap) {
                        if (!userSnap.hasData) return const SizedBox(height: 72);
                        final other = userSnap.data!;
                        return ChatTile(
                          chat: chat,
                          other: other,
                          myId: _chats.myId,
                          onTap: () => _openChat(other),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UsersScreen()),
        ),
        child: const Icon(Icons.add_comment_rounded),
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.25) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(color: selected ? AppColors.primary : AppColors.textSecondary),
        ),
      ),
    );
  }
}
