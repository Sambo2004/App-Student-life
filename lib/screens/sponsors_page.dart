import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/app_background.dart';
import '../widgets/app_shell.dart';
import '../widgets/page_header.dart';

class SponsorsPage extends StatelessWidget {
  const SponsorsPage({super.key});

  @override
  Widget build(BuildContext context) => AppShell(
    index: 5,
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(context.tr('Sponsors & partners'))),
      body: AppBackground(
        child: ListView(
          children: [
            const PageHeader(
              title: 'Our sponsors',
              subtitle: 'Supporting better student experiences.',
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.handshake_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Partner with Student Life Hub',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This space is ready for universities, student clubs, and organizations that support student success.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            const ListTile(
              leading: Icon(Icons.school_outlined),
              title: Text('University partners'),
              subtitle: Text('Help students stay organized and engaged.'),
            ),
            const ListTile(
              leading: Icon(Icons.groups_outlined),
              title: Text('Student organizations'),
              subtitle: Text(
                'Share events and build stronger campus communities.',
              ),
            ),
            const ListTile(
              leading: Icon(Icons.business_outlined),
              title: Text('Community sponsors'),
              subtitle: Text('Support practical tools for student wellbeing.'),
            ),
          ],
        ),
      ),
    ),
  );
}
