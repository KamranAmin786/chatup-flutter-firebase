import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/chat.dart';
import '../theme.dart';
import '../utils.dart';
import 'avatar.dart';

class ChatTile extends StatelessWidget {
  final Chat chat;
  final AppUser other;
  final String myId;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.chat,
    required this.other,
    required this.myId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unread = chat.unreadFor(myId);
    final typing = chat.isTyping(other.uid);
    final isMine = chat.lastSender == myId;
    final seen = chat.unreadFor(other.uid) == 0; // they opened the chat

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Avatar(name: other.name, color: other.color, online: other.online),
      title: Text(
        other.name,
        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      ),
      subtitle: Row(
        children: [
          if (isMine && !typing)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.done_all,
                size: 16,
                color: seen ? AppColors.readTick : AppColors.textSecondary,
              ),
            ),
          Expanded(
            child: Text(
              typing ? 'typing...' : chat.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: typing ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chatTime(chat.lastTime),
            style: TextStyle(
              fontSize: 12,
              color: unread > 0 ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          if (unread > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unread',
                style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
