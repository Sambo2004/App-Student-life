import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../data/app_settings.dart';
import '../data/student_store.dart';
import '../l10n/app_localizations.dart';
import '../routes/app_routes.dart';
import '../widgets/app_shell.dart';
import '../widgets/page_header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _pickProfileImage(BuildContext context) async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      await AppSettings.instance.setProfileImage(await file.readAsBytes());
    }
  }

  Future<void> _pickBackgroundImage(BuildContext context) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1200,
      imageQuality: 75,
    );
    if (file != null) {
      await AppSettings.instance.setBackgroundImage(await file.readAsBytes());
    }
  }

  Future<void> _editName(BuildContext context) async {
    final controller = TextEditingController(
      text: AppSettings.instance.displayName,
    );
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          decoration: const InputDecoration(labelText: 'Display name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              AppSettings.instance.setDisplayName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AppShell(
    index: 5,
    child: AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        final settings = AppSettings.instance;
        return ListView(
          children: [
            const PageHeader(
              title: 'Profile & settings',
              subtitle: 'Make Student Life Hub feel like yours.',
            ),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: settings.profileImage == null
                        ? null
                        : MemoryImage(settings.profileImage!),
                    child: settings.profileImage == null
                        ? const Icon(Icons.person, size: 48)
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton.filled(
                      tooltip: 'Change profile photo',
                      onPressed: () => _pickProfileImage(context),
                      icon: const Icon(Icons.camera_alt, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                settings.displayName,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton.icon(
              onPressed: () => _editName(context),
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit name'),
            ),
            const SizedBox(height: 12),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.text_fields),
                    title: Text(context.tr('Text size')),
                    subtitle: Text(_fontSizeLabel(settings.fontScale)),
                    onTap: () => _showTextSize(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.font_download_outlined),
                    title: Text(context.tr('Font style')),
                    subtitle: Text(settings.fontFamily),
                    onTap: () => _showFontPicker(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.format_color_text,
                      color: settings.textColor,
                    ),
                    title: const Text('Text color'),
                    subtitle: const Text('Change the reading color'),
                    onTap: () => _showColorPicker(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.wallpaper_outlined),
                    title: const Text('Background image'),
                    subtitle: Text(
                      settings.backgroundImage == null
                          ? 'Use your own image behind the app'
                          : 'Custom image selected',
                    ),
                    onTap: () => _pickBackgroundImage(context),
                  ),
                  if (settings.backgroundImage != null)
                    ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Remove background image'),
                      onTap: AppSettings.instance.clearBackgroundImage,
                    ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.dark_mode_outlined),
                    title: Text(context.tr('Appearance')),
                    subtitle: const Text('Choose light, dark, or system theme'),
                    onTap: () => _showThemePicker(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(context.tr('Language')),
                    subtitle: Text(
                      settings.languageCode == 'km'
                          ? context.tr('Khmer')
                          : context.tr('English'),
                    ),
                    onTap: () => _showLanguagePicker(context),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.contrast),
                    title: Text(context.tr('High contrast')),
                    subtitle: const Text('Improve text and control visibility'),
                    value: settings.highContrast,
                    onChanged: AppSettings.instance.setHighContrast,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.restart_alt),
                    title: Text(context.tr('Reset app data')),
                    subtitle: const Text(
                      'Return to a clean first-install state',
                    ),
                    onTap: () => _resetApp(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.backup_outlined),
                    title: Text(context.tr('Backup data')),
                    subtitle: const Text('Copy your student data as JSON'),
                    onTap: () => context.push(AppRoutes.backupRestore),
                  ),
                  ListTile(
                    leading: const Icon(Icons.restore_outlined),
                    title: Text(context.tr('Restore data')),
                    subtitle: const Text('Paste a previous JSON backup'),
                    onTap: () => context.push(AppRoutes.backupRestore),
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_fire_department_outlined),
                    title: Text(context.tr('Study streak')),
                    subtitle: const Text('View your daily progress habit'),
                    onTap: () => context.push(AppRoutes.studyStreak),
                  ),
                  ListTile(
                    leading: const Icon(Icons.insights_outlined),
                    title: Text(context.tr('Weekly report')),
                    subtitle: const Text('Review your routine and progress'),
                    onTap: () => context.push(AppRoutes.weeklyReport),
                  ),
                  ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: Text(context.tr('Focus timer')),
                    subtitle: const Text('Use a Pomodoro study session'),
                    onTap: () => context.push(AppRoutes.pomodoro),
                  ),
                  ListTile(
                    leading: const Icon(Icons.school_outlined),
                    title: Text(context.tr('Grades and GPA')),
                    subtitle: const Text('Track course results and GPA'),
                    onTap: () => context.push(AppRoutes.grades),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(context.tr('About us')),
                    subtitle: const Text('Learn about Student Life Hub'),
                    onTap: () => context.push(AppRoutes.about),
                  ),
                  ListTile(
                    leading: const Icon(Icons.handshake_outlined),
                    title: Text(context.tr('Sponsors & partners')),
                    subtitle: const Text('Support student success'),
                    onTap: () => context.push(AppRoutes.sponsors),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  Future<void> _showTextSize(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, _) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('Text size')),
              ...const {'Small': 0.9, 'Normal': 1.0, 'Large': 1.1}.entries.map(
                (option) => ListTile(
                  title: Text(option.key),
                  trailing: AppSettings.instance.fontScale == option.value
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    AppSettings.instance.setFontScale(option.value);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showFontPicker(BuildContext context) async {
    const fonts = ['Default', 'Serif', 'Monospace'];
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: fonts
              .map(
                (font) => ListTile(
                  title: Text(
                    font,
                    style: TextStyle(
                      fontFamily: font == 'Default' ? null : font,
                    ),
                  ),
                  trailing: AppSettings.instance.fontFamily == font
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    AppSettings.instance.setFontFamily(font);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _showColorPicker(BuildContext context) async {
    const colors = [
      Colors.black87,
      Colors.blue,
      Colors.teal,
      Colors.deepOrange,
      Colors.blueGrey,
    ];
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Wrap(
            spacing: 18,
            children: colors
                .map(
                  (color) => IconButton(
                    tooltip: 'Choose text color',
                    icon: Icon(Icons.circle, color: color, size: 34),
                    onPressed: () {
                      AppSettings.instance.setTextColor(color);
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _showThemePicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values
              .map(
                (mode) => ListTile(
                  title: Text(
                    mode.name[0].toUpperCase() + mode.name.substring(1),
                  ),
                  trailing: AppSettings.instance.themeMode == mode
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    AppSettings.instance.setThemeMode(mode);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('Language')),
            ListTile(
              title: const Text('English'),
              trailing: AppSettings.instance.languageCode == 'en'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                AppSettings.instance.setLanguageCode('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('ភាសាខ្មែរ'),
              subtitle: const Text('Khmer'),
              trailing: AppSettings.instance.languageCode == 'km'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                AppSettings.instance.setLanguageCode('km');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetApp(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset app data?'),
        content: const Text(
          'This removes your name, photo, settings, tasks, classes, events, and expenses.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await Future.wait([
      AppSettings.instance.reset(),
      StudentStore.instance.clearData(),
    ]);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('App reset to first-install state.')),
      );
    }
  }
}

String _fontSizeLabel(double scale) {
  if (scale < 0.95) return 'Small';
  if (scale > 1.05) return 'Large';
  return 'Normal';
}
