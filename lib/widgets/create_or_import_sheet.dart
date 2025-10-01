// lib/features/import/widgets/create_or_import_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/csv_import_provider.dart';

/// Reusable bottom sheet that offers two actions:
/// 1) Import questions from CSV (uses csvImportProvider)
/// 2) Make questions manually (customizable via [onMakeTap])
///
/// Key safety: We never use `ref` after the sheet is popped. We:
///  - run the import while the sheet is mounted,
///  - read the result,
///  - then pop,
///  - and finally show snackbars using the parent page's context.
class CreateOrImportSheet extends StatefulWidget {
  const CreateOrImportSheet({
    super.key,
    required this.parentContext,
    this.title = '✨ Create or Import',
    this.importLabel = 'Import from CSV',
    this.makeLabel = 'Make Questions Manually',
    this.onMakeTap,
  });

  /// The caller's (parent page) context, used for SnackBars after pop.
  final BuildContext parentContext;

  /// Top title text.
  final String title;

  /// Label for the import option.
  final String importLabel;

  /// Label for the make option.
  final String makeLabel;

  /// Callback when "Make" is tapped (e.g., navigate to create flow).
  final VoidCallback? onMakeTap;

  /// Convenience helper to show this sheet.
  static Future<void> show(
      BuildContext context, {
        String title = '✨ Create or Import',
        String importLabel = 'Import from CSV',
        String makeLabel = 'Make Questions Manually',
        VoidCallback? onMakeTap,
      }) async {
    final theme = Theme.of(context);
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CreateOrImportSheet(
        parentContext: context,
        title: title,
        importLabel: importLabel,
        makeLabel: makeLabel,
        onMakeTap: onMakeTap,
      ),
    );
  }

  @override
  State<CreateOrImportSheet> createState() => _CreateOrImportSheetState();
}

class _CreateOrImportSheetState extends State<CreateOrImportSheet> {
  bool _showFirst = false;
  bool _showSecond = false;

  @override
  void initState() {
    super.initState();
    // Staggered reveal animation
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      setState(() => _showFirst = true);
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      setState(() => _showSecond = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Consumer(
        builder: (context, ref, _) {
          final st = ref.watch(csvImportProvider);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Import card
              _AnimatedChoiceCard(
                visible: _showFirst,
                duration: const Duration(milliseconds: 260),
                offset: const Offset(0, 0.12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: st.loading
                      ? null
                      : () async {
                    // Capture notifier BEFORE popping the sheet
                    final notifier =
                    ref.read(csvImportProvider.notifier);

                    // Run import while sheet is mounted
                    await notifier.importFromPicker();

                    // Read result BEFORE pop (safe)
                    final result = ref.read(csvImportProvider);
                    if (!mounted) return;

                    // Close the sheet
                    Navigator.of(context).pop();

                    // Show snackbar from the parent context
                    final messenger =
                    ScaffoldMessenger.of(widget.parentContext);

                    if (result.error != null) {
                      messenger.showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red.shade400,
                          content:
                          Text('❌ Import failed: ${result.error}'),
                        ),
                      );
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green.shade600,
                          content: Text(
                            '✅ Imported ${result.quizzes} quiz(es), '
                                '${result.questions} question(s).',
                          ),
                        ),
                      );
                    }
                  },
                  child: Card(
                    color: theme.colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: theme.colorScheme.primary,
                            child: st.loading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Icon(
                              Icons.upload_file,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              widget.importLabel,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 28),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Make card
              _AnimatedChoiceCard(
                visible: _showSecond,
                duration: const Duration(milliseconds: 300),
                offset: const Offset(0, 0.12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onMakeTap?.call();
                  },
                  child: Card(
                    color: theme.colorScheme.secondaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: theme.colorScheme.secondary,
                            child: const Icon(
                              Icons.add_circle_outline,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              widget.makeLabel,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 28),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Slide+fade wrapper used by both cards
class _AnimatedChoiceCard extends StatelessWidget {
  const _AnimatedChoiceCard({
    required this.child,
    required this.visible,
    required this.duration,
    required this.offset,
  });

  final Widget child;
  final bool visible;
  final Duration duration;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : offset,
      duration: duration,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: duration,
        curve: Curves.easeOutCubic,
        child: child,
      ),
    );
  }
}
