import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls the "Register" button loading state (true = in progress)
final registerLoadingProvider = StateProvider<bool>((ref) => false);
