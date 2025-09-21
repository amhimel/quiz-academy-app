import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/csv_import_provider.dart';

class CsvImportPage extends ConsumerWidget {
  const CsvImportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(csvImportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Import CSV')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: st.loading
                  ? null
                  : () => ref.read(csvImportProvider.notifier).importFromPicker(),
              icon: const Icon(Icons.upload_file),
              label: Text(st.loading ? 'Importing...' : 'Pick CSV & Import'),
            ),
            const SizedBox(height: 16),
            if (st.error != null)
              Text(st.error!, style: const TextStyle(color: Colors.red)),
            if (!st.loading && st.error == null && (st.quizzes > 0 || st.questions > 0))
              Text('Imported ${st.quizzes} quizzes, ${st.questions} questions.'),
          ],
        ),
      ),
    );
  }
}
