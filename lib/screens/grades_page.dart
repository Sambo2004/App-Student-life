import 'package:flutter/material.dart';

import '../data/student_store.dart';
import '../widgets/app_shell.dart';
import '../widgets/page_header.dart';

class GradesPage extends StatelessWidget {
  const GradesPage({super.key});

  Future<void> _addGrade(BuildContext context) async {
    final course = TextEditingController();
    final credits = TextEditingController(text: '3');
    var grade = 'A';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add course grade'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: course,
                  decoration: const InputDecoration(labelText: 'Course'),
                ),
                TextField(
                  controller: credits,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Credits'),
                ),
                DropdownButtonFormField<String>(
                  initialValue: grade,
                  decoration: const InputDecoration(labelText: 'Grade'),
                  items: ['A', 'B', 'C', 'D', 'F']
                      .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) => setState(() => grade = value ?? 'A'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(credits.text) ?? 0;
                StudentStore.instance.addGrade(course.text, value, grade);
                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AppShell(
    index: 0,
    child: AnimatedBuilder(
      animation: StudentStore.instance,
      builder: (context, _) {
        final store = StudentStore.instance;
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const PageHeader(
              title: 'Grades and GPA',
              subtitle: 'Track course results and your weighted GPA.',
              showBackButton: true,
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                leading: Icon(Icons.school_outlined, color: Theme.of(context).colorScheme.primary),
                title: const Text('Current GPA'),
                trailing: Text(
                  store.gpa.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (store.grades.isEmpty)
              const ListTile(title: Text('Add your first course grade.')),
            ...store.grades.map(
              (grade) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: ListTile(
                  title: Text(grade.course),
                  subtitle: Text('${grade.credits} credits'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(grade.grade, style: Theme.of(context).textTheme.titleLarge),
                      IconButton(
                        tooltip: 'Delete grade',
                        onPressed: () => store.deleteGrade(grade),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: FilledButton.icon(
                onPressed: () => _addGrade(context),
                icon: const Icon(Icons.add),
                label: const Text('Add course grade'),
              ),
            ),
          ],
        );
      },
    ),
  );
}
