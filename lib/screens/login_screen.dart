// lib/features/auth/presentation/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/profile_model.dart';
import '../providers/auth_controller.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _doLogin() async {
    final email = _email.text.trim();
    final pass = _password.text;

    if (email.isEmpty) return _showSnack('Email is required');
    if (pass.isEmpty) return _showSnack('Password is required');

    setState(() => _loading = true);
    try {
      await ref.read(authControllerProvider).login(email, pass);
      if (!mounted) return;
      context.go('/home'); // or '/' based on your routes
    } catch (e) {
      _showSnack('Login failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Optional: listen to auth stream and redirect if already logged in
    ref.listen<AsyncValue<ProfileModel?>>(authStateProvider, (prev, next) {
      next.whenData((user) {
        if (user != null && mounted) {
          context.go('/home');
        }
      });
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Log in')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(controller: _email, label: 'Email'),
                  const SizedBox(height: 12),
                  // Using your current AppTextField API (no suffix)
                  AppTextField(
                    controller: _password,
                    label: 'Password',
                    obscureText: true, // toggle not shown since no suffix support
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Log in',
                    isLoading: _loading,
                    onPressed: _loading ? null : _doLogin,
                  ),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text('Create an account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
