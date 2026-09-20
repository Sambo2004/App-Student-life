import 'package:flutter/material.dart';

import '../widgets/app_background.dart';
import '../widgets/app_shell.dart';
import '../widgets/page_header.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) => AppShell(
    index: 5,
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('About Student Life Hubby')),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const PageHeader(
              title: 'About us',
              subtitle: 'A simpler way to manage student life.',
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Student Life Hub brings planning, study routines, campus activities, and personal budgeting together in one focused workspace. It is designed to help students spend less time organizing and more time making progress.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _InfoTile(
              icon: Icons.person_outline,
              title: 'Founder',
              body: 'Sum Sambo',
            ),
            const _InfoTile(
              icon: Icons.email_outlined,
              title: 'Email',
              body: 'sumsambo8899@gmail.com',
            ),
            const _InfoTile(
              icon: Icons.school_outlined,
              title: 'Education',
              body: 'Computer Science',
            ),
            const _InfoTile(
              icon: Icons.groups_outlined,
              title: 'Team',
              body: 'Sao Sreynet, Srun Darasthya, and Kun Korn',
            ),
            const Divider(indent: 20, endIndent: 20, height: 28),
            const _InfoTile(
              icon: Icons.track_changes,
              title: 'Our purpose',
              body:
                  'Make everyday student planning clear, calm, and practical.',
            ),
            const _InfoTile(
              icon: Icons.security,
              title: 'Privacy first',
              body: 'Your current data stays on your device and is controlled by you.',
            ),
            const _InfoTile(
              icon: Icons.auto_graph,
              title: 'Built for progress',
              body: 'Small insights help you understand your routine and improve it.',
            ),
          ],
        ),
      ),
    ),
  );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
    leading: CircleAvatar(child: Icon(icon)),
    title: Text(title),
    subtitle: Text(body),
  );
}
