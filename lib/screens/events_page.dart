import 'package:flutter/material.dart';

import '../data/student_store.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_shell.dart';
import '../widgets/page_header.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  Future<void> _showEventForm(
    BuildContext context, {
    CampusEvent? existing,
  }) async {
    final title = TextEditingController();
    final place = TextEditingController();
    final club = TextEditingController();
    final description = TextEditingController();
    var selectedDate = DateTime.now();
    var selectedTime = const TimeOfDay(hour: 12, minute: 0);
    if (existing != null) {
      title.text = existing.title;
      place.text = existing.place;
      club.text = existing.club;
      description.text = existing.description;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            existing == null ? 'Add campus event' : 'Edit campus event',
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          actionsOverflowDirection: VerticalDirection.down,
          actionsOverflowButtonSpacing: 8,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Event name'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: const Text('Date'),
                  subtitle: Text(_formatDate(selectedDate)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule_outlined),
                  title: const Text('Time'),
                  subtitle: Text(_formatTime(selectedTime)),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setDialogState(() => selectedTime = picked);
                    }
                  },
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('Cancel')),
            ),
            FilledButton(
              onPressed: () {
                if ([
                  title.text,
                  place.text,
                  club.text,
                ].any((value) => value.trim().isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.tr('Complete all event fields.'))),
                  );
                  return;
                }
                final value = CampusEvent(
                  title: title.text,
                  date:
                      '${_formatDate(selectedDate)} ${_formatTime(selectedTime)}',
                  place: place.text,
                  club: club.text,
                  description: description.text,
                );
                if (existing == null) {
                  StudentStore.instance.addEvent(
                    value.title,
                    value.date,
                    value.place,
                    value.club,
                    description: value.description,
                  );
                } else {
                  StudentStore.instance.updateEvent(existing, value);
                }
                Navigator.pop(context);
              },
              child: Text(context.tr(existing == null ? 'Add' : 'Save')),
            ),
          ],
        ),
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
          onPressed: () => _showEventForm(context),
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
                    trailing: Wrap(
                      children: [
                        IconButton(
                          tooltip: 'Edit event',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () =>
                              _showEventForm(context, existing: event),
                        ),
                        IconButton(
                          tooltip: 'Delete event',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            StudentStore.instance.deleteEvent(event);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Event deleted'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () =>
                                      StudentStore.instance.restoreEvent(event),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

String _formatTime(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  return '$hour:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
}
