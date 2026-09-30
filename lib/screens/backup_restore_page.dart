import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/student_store.dart';
import '../l10n/app_localizations.dart';
import '../services/encrypted_backup_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/page_header.dart';

class BackupRestorePage extends StatelessWidget {
  const BackupRestorePage({super.key});

  @override
  Widget build(BuildContext context) => AppShell(
    index: 5,
    child: ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const PageHeader(
          title: 'Backup & restore',
          subtitle: 'Keep a copy of your student data when you need it.',
          showBackButton: true,
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.backup_outlined),
                title: Text(context.tr('Copy backup')),
                subtitle: const Text(
                  'Copy all tasks, classes, expenses, and events as JSON.',
                ),
                onTap: () => _copyBackup(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.restore_outlined),
                title: Text(context.tr('Restore backup')),
                subtitle: const Text(
                  'Paste a JSON backup copied from this app.',
                ),
                onTap: () => _restoreBackup(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(context.tr('Copy encrypted backup')),
                subtitle: Text(context.tr('Protect the backup with a password.')),
                onTap: () => _copyEncryptedBackup(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.lock_reset_outlined),
                title: Text(context.tr('Restore encrypted backup')),
                subtitle: Text(context.tr('Restore a password-protected backup.')),
                onTap: () => _restoreEncryptedBackup(context),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Restore replaces the current student records. Create a backup first if you want to keep them.',
          ),
        ),
      ],
    ),
  );

  Future<void> _copyBackup(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: StudentStore.instance.exportBackup()),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Backup copied to clipboard.'))),
      );
    }
  }

  Future<void> _restoreBackup(BuildContext context) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('Restore backup')),
        content: TextField(
          controller: controller,
          minLines: 5,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: 'Paste JSON backup here',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.tr('Restore')),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      controller.dispose();
      return;
    }
    try {
      await StudentStore.instance.importBackup(controller.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Backup restored successfully.'))),
        );
      }
    } on FormatException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      controller.dispose();
    }
  }

  Future<void> _copyEncryptedBackup(BuildContext context) async {
    final password = await _askPassword(context, context.tr('Create backup password'));
    if (password == null || !context.mounted) return;
    try {
      final backup = await EncryptedBackupService.instance.exportBackup(password);
      await Clipboard.setData(ClipboardData(text: backup));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Encrypted backup copied.'))),
        );
      }
    } on FormatException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    }
  }

  Future<void> _restoreEncryptedBackup(BuildContext context) async {
    final source = TextEditingController();
    final password = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('Restore encrypted backup')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: source,
                minLines: 5,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: context.tr('Paste encrypted backup here'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.tr('Backup password'),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.tr('Restore')),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      source.dispose();
      password.dispose();
      return;
    }
    try {
      await EncryptedBackupService.instance.importBackup(
        source.text,
        password.text,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Backup restored successfully.'))),
        );
      }
    } on FormatException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } finally {
      source.dispose();
      password.dispose();
    }
  }

  Future<String?> _askPassword(BuildContext context, String title) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          decoration: InputDecoration(
            labelText: context.tr('Backup password'),
            helperText: context.tr('At least 8 characters'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.tr('Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text(context.tr('Continue')),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }
}
