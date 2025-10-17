import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz.dart';

final feedQuizzesProvider = FutureProvider<List<Quiz>>((ref) async {
  final sb = Supabase.instance.client;
  final res = await sb.rpc('get_feed_quizzes');
  final list = (res as List).cast<Map<String, dynamic>>();
  return list.map(Quiz.fromMap).toList();
});
// This provider fetches a list of quizzes from the Supabase backend using the 'get_feed_quizzes' RPC function and maps the result to a list of Quiz objects.