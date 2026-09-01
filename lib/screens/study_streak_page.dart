import 'package:flutter/material.dart';

import '../data/student_store.dart';
import '../widgets/app_shell.dart';
import '../widgets/page_header.dart';

class StudyStreakPage extends StatelessWidget {
  const StudyStreakPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StudentStore.instance;
    return AppShell(
      index: 5,
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const PageHeader(
              title: 'Study streak',
              subtitle: 'Small daily progress becomes a strong habit.',
              showBackButton: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${store.studyStreak} days',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        store.studyStreak == 0
                            ? 'Complete a task today to start your streak.'
                            : 'Keep going tomorrow to continue your streak.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('How it works'),
              subtitle: Text(
                'Your streak increases when you complete at least one task in a day. The history is stored privately on this device.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
