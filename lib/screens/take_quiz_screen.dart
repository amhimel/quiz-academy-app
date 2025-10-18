import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quiz_academy/providers/quiz_by_id_provider.dart';
import 'package:quiz_academy/providers/questions_by_quiz_provider.dart';

import '../models/question.dart';
import '../models/attempt_payload.dart';
import '../providers/attempt_submit_provider.dart';

class TakeQuizScreen extends ConsumerStatefulWidget {
  final String quizId;
  const TakeQuizScreen({super.key, required this.quizId});

  @override
  ConsumerState<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends ConsumerState<TakeQuizScreen> {
  // selection & tracking
  final Map<String, int> _answers = {};            // qId -> selectedIndex
  final Map<String, int> _changeCount = {};        // qId -> times selection CHANGED
  final Map<String, List<int>> _tapCounts = {};    // qId -> per-option taps

  // view/progress
  List<Question> _latestQuestions = const [];
  int _index = 0;

  // timer
  int _secondsLeft = 0;
  bool _timerStarted = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ---------- helpers ----------

  void _maybeStartTimer(int durationMinutes) {
    if (_timerStarted) return;
    _timerStarted = true;
    final alloc = max(1, durationMinutes) * 60;
    _secondsLeft = alloc;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secondsLeft = max(0, _secondsLeft - 1));
      if (_secondsLeft <= 0) {
        t.cancel();
        _submit(auto: true);
      }
    });
  }

  void _initCounters(List<Question> questions) {
    for (final q in questions) {
      _changeCount.putIfAbsent(q.id, () => 0);
      _tapCounts.putIfAbsent(q.id, () => List.filled(q.options.length, 0));
    }
  }

  void _select(String qId, int optionIndex) {
    setState(() {
      // per-option tap
      final taps = _tapCounts[qId];
      if (taps != null) {
        if (optionIndex >= taps.length) {
          taps.addAll(List.filled(optionIndex - taps.length + 1, 0));
        }
        taps[optionIndex] = taps[optionIndex] + 1;
      }
      // only count when selection CHANGES
      final prev = _answers[qId];
      if (prev != optionIndex) {
        _changeCount[qId] = (_changeCount[qId] ?? 0) + 1;
        _answers[qId] = optionIndex;
      }
    });
  }

  void _next(int total) {
    if (_index < total - 1) setState(() => _index++);
  }

  double _difficultyMultiplier(String type) {
    final t = type.toLowerCase();
    if (t.contains('hard')) return 1.5;
    if (t.contains('medium')) return 1.2;
    if (t.contains('easy')) return 1.0;
    return 1.0; // general / unknown
  }

  String _fmtMMSS(int secs) {
    final m = secs ~/ 60, s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ---------- SUBMIT (Riverpod) ----------

  Future<void> _submit({bool auto = false}) async {
    _timer?.cancel();

    // snapshot
    var qs = _latestQuestions;
    if (qs.isEmpty) {
      final async = ref.read(questionsByQuizProvider(widget.quizId));
      qs = async.value ?? const <Question>[];
    }
    final quiz = ref.read(quizByIdProvider(widget.quizId)).value;

    // compute result
    int correct = 0;
    for (final q in qs) {
      final sel = _answers[q.id];
      if (sel != null && sel == q.correctIndex) correct++;
    }
    final totalQ = qs.length;

    final durationMin = int.tryParse((quiz?.durationMinutes ?? '0')) ?? 0;
    final allocatedSec = max(1, durationMin) * 60;
    final timeSpentSec = (allocatedSec - _secondsLeft).clamp(0, allocatedSec);

    final totalChanges = _changeCount.values.fold<int>(0, (a, b) => a + b);
    final totalTaps = _tapCounts.values
        .fold<int>(0, (a, list) => a + list.fold<int>(0, (x, y) => x + y));
    final extraChanges = max(0, totalChanges - totalQ);

    // scoring
    const basePerCorrect = 100;
    final diffMult = _difficultyMultiplier(quiz?.type ?? '');
    final speedBonus = ((_secondsLeft / allocatedSec) * 100).clamp(0, 100);
    final raw = (correct * basePerCorrect * diffMult + speedBonus).round();
    final clickPenalty = extraChanges * 5; // প্রতি extra change -5
    final finalScore = max(0, raw - clickPenalty);

    // tapCounts JSON
    final tapCountsJson = {
      for (final q in qs)
        q.id: {
          'changes': _changeCount[q.id] ?? 0,
          'per_option': _tapCounts[q.id] ?? List.filled(q.options.length, 0),
        }
    };

    // answers map
    final answersMap = {
      for (final q in qs)
        if (_answers[q.id] != null) q.id: _answers[q.id]!,
    };

    // payload
    final payload = AttemptPayload(
      quizId: widget.quizId,
      correctCount: correct,
      totalQuestions: totalQ,
      timeSpentSec: timeSpentSec,
      score: finalScore,
      tapCountTotal: totalTaps,
      changeCountTotal: totalChanges,
      tapCounts: tapCountsJson,
      answers: answersMap,
      finishedAt: DateTime.now(),
    );

    // Riverpod submit
    final controller = ref.read(attemptSubmitControllerProvider.notifier);
    await controller.submit(payload);

    final submitState = ref.read(attemptSubmitControllerProvider);
    if (submitState.hasError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: ${submitState.error}')),
        );
      }
    }

    _showResult(qs, correct, finalScore, timeSpentSec, totalTaps, totalChanges,
        auto: auto);
  }

  void _showResult(
      List<Question> questions,
      int correct,
      int score,
      int timeSpentSec,
      int totalTaps,
      int totalChanges, {
        bool auto = false,
      }) {
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
              style:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              "Score: $score   •   $correct / $total correct",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              "Time: ${_fmtMMSS(timeSpentSec)}   •   Taps: $totalTaps   •   Changes: $totalChanges",
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: total == 0 ? 0 : correct / total,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(); // close sheet
                Navigator.of(context).maybePop(); // leave screen
              },
              child: const Text("Close"),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(quizByIdProvider(widget.quizId));
    final qsAsync = ref.watch(questionsByQuizProvider(widget.quizId));
    final submitState = ref.watch(attemptSubmitControllerProvider);

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

                _latestQuestions = questions;
                _initCounters(questions);

                final q = questions[_index];
                final total = questions.length;
                final selected = _answers[q.id];

                final isSubmitting = submitState.isLoading;

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
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),

                      // segmented progress
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
                                    "${duration}min  |  ${_fmtMMSS(_secondsLeft)}",
                                    bg: const Color(0xFF7B7B7B),
                                    fg: Colors.white,
                                  ),
                                  const Spacer(),
                                  Text("${_index + 1} / $total",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
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
                          onPressed: isSubmitting || selected == null
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
                          child: isSubmitting
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                              : Text(_index == total - 1 ? "Submit" : "Next"),
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

/// --- UI BITS ---

class _ChipBadge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _ChipBadge({required this.text, required this.bg, required this.fg});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(text,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 1.2),
          ),
          child: Row(
            children: [
              Text(labelPrefix,
                  style: TextStyle(fontWeight: FontWeight.w800, color: fg)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(text,
                    style: TextStyle(
                        fontSize: 15, color: fg, fontWeight: FontWeight.w600)),
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
