import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/auth_form.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  Future<void> _signUp() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await AuthService().signUp(_name.text.trim(), _email.text.trim(), _password.text);
      if (mounted) Navigator.pop(context); // AuthGate shows the home screen
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Sign up failed')),
      );
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const AppLogo(),
              const SizedBox(height: 8),
              const Text('Create your account', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 36),
              AuthField(controller: _name, hint: 'Your name', icon: Icons.person_outline),
              AuthField(controller: _email, hint: 'Email', icon: Icons.email_outlined),
              AuthField(
                controller: _password,
                hint: 'Password (6+ characters)',
                icon: Icons.lock_outline,
                obscure: true,
              ),
              const SizedBox(height: 10),
              PrimaryButton(label: 'Sign up', loading: _loading, onPressed: _signUp),
            ],
          ),
        ),
      ),
    );
  }
}
