// lib/features/auth/presentation/complete_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_controller.dart';
import '../providers/complete_profile_state.dart';
import '../providers/profile_completion_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class CompleteProfileScreen extends ConsumerWidget {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If user somehow completes in background, bounce home
    final needs = ref.watch(needsProfileCompletionProvider);
    if (!needs) {
      Future.microtask(() => context.go('/home'));
    }

    final name = ref.watch(completeNameProvider);
    final file = ref.watch(completeAvatarFileProvider);
    final saving = ref.watch(completeSavingProvider);

    Future<void> pickAvatar() async {
      try {
        final img = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (img != null) {
          ref.read(completeAvatarFileProvider.notifier).state = File(img.path);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image pick failed: $e')));
      }
    }

    Future<void> save() async {
      if ((name.trim().isEmpty) && file == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add a name or pick an image')),
        );
        return;
      }
      ref.read(completeSavingProvider.notifier).state = true;
      try {
        await ref.read(authControllerProvider).updateProfile(
          displayName: name.trim().isEmpty ? null : name.trim(),
          avatarFile: file,
        );

        // Refresh auth state so redirect reevaluates
        ref.invalidate(authStateProvider);

        if (context.mounted) context.go('/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      } finally {
        ref.read(completeSavingProvider.notifier).state = false;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Complete your profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: saving ? null : pickAvatar,
              child: CircleAvatar(
                radius: 48,
                backgroundImage: file != null ? FileImage(file) : null,
                child: file == null ? const Icon(Icons.camera_alt, size: 28) : null,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Display name',
              controller: TextEditingController(text: name)
                ..selection = TextSelection.collapsed(offset: name.length),
              // Update provider on every change
              onChanged: (v) => ref.read(completeNameProvider.notifier).state = v,
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Save',
              isLoading: saving,
              onPressed: saving ? null : save,
            ),
            const SizedBox(height: 8),
            const Text('Add a name and an avatar to continue.'),
          ],
        ),
      ),
    );
  }
}
