import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/question.dart';
import '../providers/questions_by_quiz_provider.dart';
import '../providers/quiz_by_id_provider.dart';

class TakeQuizScreen extends ConsumerStatefulWidget {
  final String quizId;
  const TakeQuizScreen({super.key, required this.quizId});

  @override
  ConsumerState<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends ConsumerState<TakeQuizScreen> {
  final Map<String, int> _answers = {}; // questionId -> selectedIndex
  int _index = 0;

  // timer
  int _secondsLeft = 0;
  bool _timerStarted = false;
  Timer? _timer;

  // 🔧 fix: keep the latest questions so submit never touches AsyncValue
  List<Question> _latestQuestions = const [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _maybeStartTimer(int durationMinutes) {
    if (_timerStarted) return;
    _timerStarted = true;
    _secondsLeft = (durationMinutes <= 0 ? 1 : durationMinutes) * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secondsLeft = (_secondsLeft - 1).clamp(0, 1 << 30));
      if (_secondsLeft <= 0) {
        t.cancel();
        _submit(auto: true);
      }
    });
  }

  void _select(String qId, int optionIndex) {
    setState(() => _answers[qId] = optionIndex);
  }

  void _next(int total) {
    if (_index < total - 1) setState(() => _index++);
  }

  // 🔧 fix: use cached _latestQuestions (fallback to provider.value if needed)
  void _submit({bool auto = false}) {
    _timer?.cancel();
    var qs = _latestQuestions;
    if (qs.isEmpty) {
      final async = ref.read(questionsByQuizProvider(widget.quizId));
      qs = async.value ?? const <Question>[];
    }
    _showResult(qs, auto: auto);
  }

  void _showResult(List<Question> questions, {bool auto = false}) {
    int score = 0;
    for (final q in questions) {
      final sel = _answers[q.id];
      if (sel != null && sel == q.correctIndex) score++;
    }
    final total = questions.length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44, height: 5,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              auto ? "Time’s up!" : "Quiz submitted",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text("Your score is $score / $total",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: total == 0 ? 0 : score / total,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).maybePop();
              },
              child: const Text("Close"),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  String _fmt(int secs) {
    final m = secs ~/ 60, s = secs % 60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(quizByIdProvider(widget.quizId));
    final qsAsync = ref.watch(questionsByQuizProvider(widget.quizId));

    return Scaffold(
      backgroundColor: const Color(0xFFF3EBDD),
      body: SafeArea(
        child: quizAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Failed to load quiz: $e')),
          data: (quiz) {
            final duration = int.tryParse(quiz.durationMinutes) ?? 0;
            _maybeStartTimer(duration);

            return qsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Failed to load questions: $e')),
              data: (questions) {
                if (questions.isEmpty) {
                  return const Center(child: Text('No questions found'));
                }

                // 🔧 keep a fresh copy for submit
                _latestQuestions = questions;

                final q = questions[_index];
                final total = questions.length;
                final selected = _answers[q.id];

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              quiz.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.w800),
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),

                      _SegmentedProgress(
                        current: _index,
                        total: total,
                        activeColor: const Color(0xFF4E63FF),
                      ),
                      const SizedBox(height: 14),

                      // Card
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.06),
                                blurRadius: 14,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _ChipBadge(
                                    text: _niceType(quiz.type),
                                    bg: const Color(0xFFF5C4C4),
                                    fg: Colors.black87,
                                  ),
                                  const SizedBox(width: 8),
                                  _ChipBadge(
                                    text:
                                    "${duration}min  |  ${_fmt(_secondsLeft)}",
                                    bg: const Color(0xFF7B7B7B),
                                    fg: Colors.white,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                q.text,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 14),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: q.options.length,
                                  separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                                  itemBuilder: (_, i) => _OptionTile(
                                    labelPrefix:
                                    '${String.fromCharCode(97 + i)})',
                                    text: q.options[i],
                                    selected: selected == i,
                                    onTap: () => _select(q.id, i),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: selected == null
                              ? null
                              : () {
                            if (_index == total - 1) {
                              _submit();
                            } else {
                              _next(total);
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF4E63FF),
                            padding:
                            const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                          Text(_index == total - 1 ? "Submit" : "Next"),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// UI helpers

class _ChipBadge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _ChipBadge({required this.text, required this.bg, required this.fg});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String labelPrefix;
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _OptionTile({
    required this.labelPrefix,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final base = selected ? const Color(0xFF4E63FF) : Colors.white;
    final border = selected ? const Color(0xFF4E63FF) : Colors.black12;
    final fg = selected ? Colors.white : Colors.black87;

    return Material(
      color: base,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 1.2),
          ),
          child: Row(
            children: [
              Text(
                labelPrefix,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentedProgress extends StatelessWidget {
  final int current;
  final int total;
  final Color activeColor;
  const _SegmentedProgress({
    required this.current,
    required this.total,
    this.activeColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final filled = i < current;
        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: filled ? activeColor : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

String _niceType(String s) {
  if (s.isEmpty) return "General";
  final r = RegExp(r'(?<=[a-z])(?=[A-Z])');
  return s.replaceAll(r, ' ');
}
