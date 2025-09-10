import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Text in the "Display name" field (optional to use; you can also read from a controller)
final completeNameProvider = StateProvider<String>((ref) => '');

/// Picked image file for the avatar
final completeAvatarFileProvider = StateProvider<File?>((ref) => null);

/// Saving flag for the Complete Profile form (so we avoid setState)
final completeSavingProvider = StateProvider<bool>((ref) => false);
