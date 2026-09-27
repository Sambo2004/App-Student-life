import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/app_settings.dart';
import '../data/student_store.dart';
import '../routes/app_routes.dart';
import '../widgets/app_shell.dart';
import '../widgets/analytics_dashboard.dart';
import '../widgets/page_header.dart';
import '../widgets/routine_chart.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => AppShell(
    index: 0,
    child: AnimatedBuilder(
      animation: StudentStore.instance,
      builder: (context, _) {
        final store = StudentStore.instance;
        final openTasks = store.tasks.where((task) => !task.done).toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
        final focusTask = openTasks.isEmpty ? null : openTasks.first;
        return AnimatedBuilder(
          animation: AppSettings.instance,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: PageHeader(
                        title:
                            'Good morning, ${AppSettings.instance.displayName}',
                        subtitle: 'Here is your day at a glance.',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Search your student life',
                            onPressed: () => showSearch<void>(
                              context: context,
                              delegate: _StudentSearchDelegate(),
                            ),
                            icon: const Icon(Icons.search_rounded),
                          ),
                          CircleAvatar(
                            radius: 28,
                            backgroundImage:
                                AppSettings.instance.profileImage == null
                                ? null
                                : MemoryImage(
                                    AppSettings.instance.profileImage!,
                                  ),
                            child: AppSettings.instance.profileImage == null
                                ? const Icon(Icons.person, size: 28)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.task_alt,
                        label: 'Tasks done',
                        value: '${store.completedTasks}/${store.tasks.length}',
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.wallet,
                        label: 'Spent',
                        value: 'USD ${store.totalExpenses.toStringAsFixed(2)}',
                        color: Theme.of(context).colorScheme.secondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              if (store.storageError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: ListTile(
                      leading: Icon(
                        Icons.warning_amber_rounded,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      title: Text(
                        'Local data notice',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                      subtitle: Text(
                        store.storageError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Today\'s focus',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text('${store.studyStreak} day streak'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          focusTask == null
                              ? 'You are all caught up. Enjoy the space.'
                              : focusTask.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          focusTask == null
                              ? 'No open tasks right now.'
                              : 'Next deadline: ${_dateText(focusTask.dueDate)}',
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: () => context.go(AppRoutes.planner),
                              icon: const Icon(Icons.calendar_month_outlined),
                              label: const Text('Planner'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  context.go(AppRoutes.weeklyReport),
                              icon: const Icon(Icons.insights_outlined),
                              label: const Text('Report'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _showQuickAdd(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Quick add'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnalyticsDashboard(store: store),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Weekly momentum',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text('${store.completedTasks} completed'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: store.tasks.isEmpty
                              ? 0
                              : store.completedTasks / store.tasks.length,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Routine forecast',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${store.tasks.where((task) => task.isOverdue).length} overdue',
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your task load for the next seven days',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _LegendDot(label: 'Planned', muted: true),
                            SizedBox(width: 12),
                            _LegendDot(label: 'Open'),
                          ],
                        ),
                        RoutineChart(tasks: store.tasks),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const _SectionTitle(title: 'Upcoming tasks'),
              if (store.tasks.isEmpty)
                const ListTile(title: Text('You are all caught up.'))
              else
                ...store.tasks
                    .take(3)
                    .map(
                      (task) => ListTile(
                        leading: Icon(
                          task.isExam
                              ? Icons.school
                              : Icons.assignment_outlined,
                        ),
                        title: Text(task.title),
                        subtitle: Text(
                          '${task.isExam ? 'Exam' : 'Assignment'} - Due ${_dateText(task.dueDate)}',
                        ),
                        trailing: task.done
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.tertiary,
                              )
                            : null,
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: OutlinedButton(
                  onPressed: () => context.go(AppRoutes.tasks),
                  child: const Text('View all tasks'),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  void _showQuickAdd(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('What would you like to add?')),
            _QuickAddTile(
              icon: Icons.task_alt,
              title: 'Task',
              route: AppRoutes.tasks,
            ),
            _QuickAddTile(
              icon: Icons.calendar_month,
              title: 'Class',
              route: AppRoutes.schedule,
            ),
            _QuickAddTile(
              icon: Icons.event,
              title: 'Event',
              route: AppRoutes.events,
            ),
            _QuickAddTile(
              icon: Icons.wallet,
              title: 'Expense',
              route: AppRoutes.expenses,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAddTile extends StatelessWidget {
  const _QuickAddTile({
    required this.icon,
    required this.title,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String route;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    onTap: () {
      Navigator.pop(context);
      context.go(route);
    },
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    color: color,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label),
        ],
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
    child: Text(title, style: Theme.of(context).textTheme.titleLarge),
  );
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, this.muted = false});

  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary
              .withValues(alpha: muted ? 0.3 : 1),
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}

String _dateText(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

class _StudentSearchDelegate extends SearchDelegate<void> {
  @override
  String get searchFieldLabel => 'Search tasks, classes, events...';

  List<_SearchItem> _items() {
    final store = StudentStore.instance;
    return [
      ...store.tasks.map(
        (task) => _SearchItem(
          title: task.title,
          subtitle: '${task.category} - ${_dateText(task.dueDate)}',
          route: AppRoutes.tasks,
          icon: task.isExam ? Icons.school_outlined : Icons.task_alt_outlined,
          searchText: '${task.title} ${task.category} ${task.notes}',
        ),
      ),
      ...store.schedule.map(
        (item) => _SearchItem(
          title: item.subject,
          subtitle: '${item.day} - ${item.time} - ${item.room}',
          route: AppRoutes.schedule,
          icon: Icons.calendar_month_outlined,
          searchText:
              '${item.subject} ${item.day} ${item.room} ${item.instructor}',
        ),
      ),
      ...store.events.map(
        (event) => _SearchItem(
          title: event.title,
          subtitle: '${event.date} - ${event.place}',
          route: AppRoutes.events,
          icon: Icons.event_outlined,
          searchText:
              '${event.title} ${event.club} ${event.place} ${event.description}',
        ),
      ),
      ...store.expenses.map(
        (expense) => _SearchItem(
          title: expense.title,
          subtitle:
              'USD ${expense.amount.toStringAsFixed(2)} - ${expense.category}',
          route: AppRoutes.expenses,
          icon: Icons.wallet_outlined,
          searchText:
              '${expense.title} ${expense.category} ${expense.paymentMethod} ${expense.notes}',
        ),
      ),
    ];
  }

  List<_SearchItem> _matches() {
    final query = this.query.trim().toLowerCase();
    if (query.isEmpty) return _items();
    return _items()
        .where((item) => item.searchText.toLowerCase().contains(query))
        .toList();
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        tooltip: 'Clear search',
        onPressed: () => query = '',
        icon: const Icon(Icons.clear),
      ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    tooltip: 'Close search',
    onPressed: () => close(context, null),
    icon: const Icon(Icons.arrow_back),
  );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final matches = _matches();
    if (matches.isEmpty) {
      return const Center(child: Text('No matching student records'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: matches.length,
      separatorBuilder: (_, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = matches[index];
        return ListTile(
          leading: CircleAvatar(child: Icon(item.icon)),
          title: Text(item.title),
          subtitle: Text(item.subtitle),
          onTap: () {
            close(context, null);
            context.go(item.route);
          },
        );
      },
    );
  }
}

class _SearchItem {
  const _SearchItem({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.searchText,
  });

  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
  final String searchText;
}
