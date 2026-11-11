import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/app_user.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/avatar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

class ChatScreen extends StatefulWidget {
  final String otherId;

  const ChatScreen({super.key, required this.otherId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chats = ChatService();
  bool _sendingImage = false;

  String get _chatId => _chats.chatId(widget.otherId);

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1080);
    if (file == null) return;
    setState(() => _sendingImage = true);
    await _chats.sendImage(widget.otherId, await file.readAsBytes());
    if (mounted) setState(() => _sendingImage = false);
  }

  void _showMessageMenu(Message message) {
    if (message.senderId != _chats.myId || message.deleted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
          title: const Text('Delete for everyone'),
          onTap: () {
            Navigator.pop(context);
            _chats.deleteMessage(widget.otherId, message.id);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _chats.setTyping(widget.otherId, false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: StreamBuilder<AppUser>(
          stream: _chats.userStream(widget.otherId),
          builder: (context, userSnap) {
            if (!userSnap.hasData) return const SizedBox();
            final other = userSnap.data!;
            return StreamBuilder<Chat?>(
              stream: _chats.chatStream(_chatId),
              builder: (context, chatSnap) {
                final typing = chatSnap.data?.isTyping(other.uid) ?? false;
                final status = typing
                    ? 'typing...'
                    : other.online
                        ? 'online'
                        : lastSeenText(other.lastSeen);
                return Row(
                  children: [
                    Avatar(name: other.name, color: other.color, size: 40),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(other.name, style: const TextStyle(fontSize: 17)),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: typing ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.videocam_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.call_outlined)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chats.messages(_chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                // new messages arrived while the chat is open -> mark them read
                if (messages.any((m) => m.senderId == widget.otherId && !m.read)) {
                  _chats.markAsRead(widget.otherId);
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final message = messages[i];
                    final older = i + 1 < messages.length ? messages[i + 1] : null;
                    final newDay = older == null || dayLabel(older.time) != dayLabel(message.time);
                    return Column(
                      children: [
                        if (newDay) _DayChip(label: dayLabel(message.time)),
                        GestureDetector(
                          onLongPress: () => _showMessageMenu(message),
                          child: MessageBubble(message: message, isMe: message.senderId == _chats.myId),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          if (_sendingImage)
            const LinearProgressIndicator(minHeight: 2, color: AppColors.primary),
          MessageInput(
            onSend: (text) => _chats.sendMessage(widget.otherId, text: text),
            onImage: _pickImage,
            onTyping: (typing) => _chats.setTyping(widget.otherId, typing),
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;

  const _DayChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    );
  }
}
