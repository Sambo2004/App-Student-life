import 'package:flutter/material.dart';

import '../data/app_settings.dart';
import '../data/student_store.dart';
import '../l10n/app_localizations.dart';
import '../services/report_export_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/page_header.dart';

class WeeklyReportPage extends StatelessWidget {
  const WeeklyReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StudentStore.instance;
    return AppShell(
      index: 0,
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final completion = store.tasks.isEmpty
              ? 0.0
              : store.completedTasks / store.tasks.length;
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
            const PageHeader(
              title: 'Weekly report',
              subtitle: 'A simple reflection on your current routine.',
              showBackButton: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _exportWord(context, store),
                      icon: const Icon(Icons.description_outlined),
                      label: Text(context.tr('Word')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => _exportPdf(context, store),
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: Text(context.tr('PDF')),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('Overall progress'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: completion, minHeight: 10),
                      const SizedBox(height: 8),
                      Text(
                        '${(completion * 100).round()}% ${context.tr('of your tasks are complete.')}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _ReportTile(
              icon: Icons.local_fire_department_outlined,
              title: 'Study streak',
              value: '${store.studyStreak} days',
            ),
            _ReportTile(
              icon: Icons.task_alt,
              title: 'Tasks completed',
              value: '${store.completedTasks}',
            ),
            _ReportTile(
              icon: Icons.calendar_month_outlined,
              title: 'Classes planned',
              value: '${store.schedule.length}',
            ),
            _ReportTile(
              icon: Icons.wallet_outlined,
              title: 'Total spending',
              value: 'USD ${store.totalExpenses.toStringAsFixed(2)}',
            ),
            _ReportTile(
              icon: Icons.event_outlined,
              title: 'Campus events',
              value: '${store.events.length}',
            ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _exportWord(BuildContext context, StudentStore store) async {
    try {
      await ReportExportService.shareWord(
        store,
        AppSettings.instance.displayName,
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not export the Word report.')),
        );
      }
    }
  }

  Future<void> _exportPdf(BuildContext context, StudentStore store) async {
    try {
      await ReportExportService.sharePdf(
        store,
        AppSettings.instance.displayName,
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not export the PDF report.')),
        );
      }
    }
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    child: ListTile(
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(context.tr(title)),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}
