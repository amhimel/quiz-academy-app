import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/quiz.dart';
import '../providers/search_quiz_provider.dart';
import '../widgets/shared_quiz_card.dart';

class SearchQuizScreen extends ConsumerStatefulWidget {
  const SearchQuizScreen({super.key});

  @override
  ConsumerState<SearchQuizScreen> createState() => _SearchQuizScreenState();
}

class _SearchQuizScreenState extends ConsumerState<SearchQuizScreen> {
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      // Optional UX: show a snack or validation text, but no setState needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a quiz code')),
      );
      return;
    }
    ref.read(quizSearchQueryProvider.notifier).state = code;
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(quizSearchQueryProvider);

    // When there's no query yet, we keep a constant AsyncData(null)
    final AsyncValue<Quiz?> result = (query == null || query.isEmpty)
        ? const AsyncData<Quiz?>(null)
        : ref.watch(quizByCodeProvider(query));

    final isSearching = result.isLoading;
    final errorText = result.whenOrNull(error: (e, _) => e.toString());
    final Quiz? found = result.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF3EBDD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quiz Found!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),

              // Search block (your design)
              Container(
                height: 170,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.06),
                      blurRadius: 10,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: const Text('Enter Quiz code',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87)),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xBBF7F7FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                          child: TextField(
                            controller: _codeCtrl,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Q-452-456',
                            ),
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _triggerSearch(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: isSearching ? null : _triggerSearch,
                          icon: const Icon(Icons.search, size: 18),
                          label: const Text('Search Quiz'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F3CFF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (errorText != null) ...[
                const SizedBox(height: 10),
                Text(errorText,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],

              const SizedBox(height: 12),

              // Result area
              Expanded(
                child: isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : (query == null || query.isEmpty)
                    ? const SizedBox.shrink()
                    : (found == null
                    ? Center(
                  child: Text(
                    'No quiz found for "$query"',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                )
                    : ListView(
                  padding: const EdgeInsets.only(top: 6),
                  children: [
                    Text(
                      found.code,
                      style: TextStyle(
                        fontSize: 18,
                        letterSpacing: .5,
                        color: Colors.black.withOpacity(.65),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SharedQuizCard(
                      quiz: found,
                      onStart: () => context.push('/take-quiz', extra: found.id),
                    ),
                  ],
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
