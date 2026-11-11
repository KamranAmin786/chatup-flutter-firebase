import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/chat_service.dart';
import '../theme.dart';
import '../widgets/auth_form.dart';
import '../widgets/avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _chats = ChatService();
  final _name = TextEditingController();
  final _about = TextEditingController();
  bool _loaded = false;
  bool _saving = false;

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await _chats.updateProfile(_name.text.trim(), _about.text.trim());
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: StreamBuilder<AppUser>(
        stream: _chats.userStream(_chats.myId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final me = snapshot.data!;
          // fill the fields once, so typing is not overwritten by the stream
          if (!_loaded) {
            _name.text = me.name;
            _about.text = me.about;
            _loaded = true;
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(child: Avatar(name: me.name, color: me.color, size: 120)),
              const SizedBox(height: 12),
              Center(
                child: Text(me.email, style: const TextStyle(color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 32),
              AuthField(controller: _name, hint: 'Name', icon: Icons.person_outline),
              AuthField(controller: _about, hint: 'About', icon: Icons.info_outline),
              const SizedBox(height: 10),
              PrimaryButton(label: 'Save', loading: _saving, onPressed: _save),
            ],
          );
        },
      ),
    );
  }
}
