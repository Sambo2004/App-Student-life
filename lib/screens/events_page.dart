import 'package:flutter/material.dart';

import '../data/student_store.dart';
import '../widgets/app_shell.dart';
import '../widgets/page_header.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  Future<void> _addEvent(BuildContext context) async {
    final title = TextEditingController();
    final date = TextEditingController();
    final place = TextEditingController();
    final club = TextEditingController();
    final description = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add campus event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Event name'),
            ),
            TextField(
              controller: date,
              decoration: const InputDecoration(labelText: 'Date and time'),
            ),
            TextField(
              controller: place,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: club,
              decoration: const InputDecoration(labelText: 'Organizer'),
            ),
            TextField(
              controller: description,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if ([
                title.text,
                date.text,
                place.text,
                club.text,
              ].any((value) => value.trim().isEmpty)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Complete all event fields.')),
                );
                return;
              }
              StudentStore.instance.addEvent(
                title.text,
                date.text,
                place.text,
                club.text,
                description: description.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AppShell(
    index: 4,
    child: AnimatedBuilder(
      animation: StudentStore.instance,
      builder: (context, _) => Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _addEvent(context),
          icon: const Icon(Icons.add),
          label: const Text('Event'),
        ),
        body: ListView(
          children: [
            const PageHeader(
              title: 'Campus events',
              subtitle: 'Discover clubs and activities.',
            ),
            if (StudentStore.instance.events.isEmpty)
              const ListTile(title: Text('No events added yet.'))
            else
              ...StudentStore.instance.events.map(
                (event) => Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.celebration)),
                    title: Text(event.title),
                    subtitle: Text(
                      '${event.club} - ${event.date}\n${event.place}${event.description.isEmpty ? '' : '\n${event.description}'}',
                    ),
                    isThreeLine: event.description.isNotEmpty,
                    trailing: IconButton(
                      tooltip: 'Delete event',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => StudentStore.instance.deleteEvent(event),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
