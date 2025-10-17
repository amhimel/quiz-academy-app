import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz.dart';
import '../providers/creator_name_provider.dart';
import 'card_button.dart';

class FeedQuizCard extends ConsumerWidget {
  final Quiz quiz;
  final VoidCallback? onTap;
  final VoidCallback? onStart;

  const FeedQuizCard( {super.key, required this.quiz, this.onTap,this.onStart,});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameAsync = ref.watch(creatorNameProvider(quiz.createdBy));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        color: const Color(0xFFFAF4E9),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 2),
              _LeadingBadge(numQuestions: quiz.numQuestions),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(
                          quiz.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _Chip(text: "${quiz.durationMinutes} min"),
                    ]),
                    const SizedBox(height: 6),
                    Text(
                      quiz.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black.withOpacity(.7),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _Chip(
                          icon: Icons.category_outlined,
                          text: _niceType(quiz.type),
                        ),
                        // const SizedBox(height: 8),
                        // _Chip(
                        //   icon: Icons.schedule,
                        //   text: _relativeTime(quiz.createdAt),
                        // ),
                        //_Chip(  icon: Icons.link_outlined,  text: quiz.code,  ),


                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            nameAsync.when(
                              data: (name) => _Chip(
                                icon: Icons.person_outline,
                                text: "By ${name ?? _shortId(quiz.createdBy)}",
                              ),
                              loading: () => const _Chip(
                                icon: Icons.person_outline,
                                text: "By …",
                              ),
                              error: (_, _) => _Chip(
                                icon: Icons.person_outline,
                                text: "By ${_shortId(quiz.createdBy)}",
                              ),
                            ),
                            CardButton(
                              label: "Start Now",
                              onPressed: onStart,
                              expanded: false,
                              // compact button
                              backgroundColor: const Color(0xFF4E63FF),
                              textColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              borderRadius: 22,
                            ),
                          ],
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeadingBadge extends StatelessWidget {
  final String numQuestions;
  const _LeadingBadge({required this.numQuestions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withOpacity(.06),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.quiz_outlined, size: 26),
          const SizedBox(height: 6),
          Text(
            numQuestions,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const Text("Qns", style: TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final IconData? icon;
  const _Chip({required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.black.withOpacity(.06),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// helpers
String _niceType(String s) {
  if (s.isEmpty) return "General";
  final r = RegExp(r'(?<=[a-z])(?=[A-Z])');
  return s.replaceAll(r, ' ');
}

String _shortId(String s) => s.length > 6 ? "${s.substring(0, 6)}…" : s;

String _relativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
  if (diff.inHours < 24) return "${diff.inHours}h ago";
  return "${diff.inDays}d ago";
}
