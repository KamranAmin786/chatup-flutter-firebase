import 'package:flutter/material.dart';

import '../theme.dart';

class MessageInput extends StatefulWidget {
  final ValueChanged<String> onSend;
  final VoidCallback onImage;
  final ValueChanged<bool> onTyping;

  const MessageInput({
    super.key,
    required this.onSend,
    required this.onImage,
    required this.onTyping,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  bool _hasText = false;

  void _changed(String value) {
    final hasText = value.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
      widget.onTyping(hasText);
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
    _changed('');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.emoji_emotions_outlined, color: AppColors.textSecondary),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: _changed,
                        onSubmitted: (_) => _send(),
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Message',
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onImage,
                      icon: const Icon(Icons.attach_file, color: AppColors.textSecondary),
                    ),
                    if (!_hasText)
                      IconButton(
                        onPressed: widget.onImage,
                        icon: const Icon(Icons.camera_alt, color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.primary,
              child: IconButton(
                onPressed: _send,
                icon: Icon(_hasText ? Icons.send : Icons.mic, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
