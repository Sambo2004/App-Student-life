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

  Future<void> _pickBackgroundImage(
    BuildContext context, {
    required _BackgroundImageSize size,
  }) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: size.maxWidth,
      maxHeight: size.maxHeight,
      imageQuality: size.quality,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      if (bytes.length > 4 * 1024 * 1024 && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please choose a smaller image.')),
        );
        return;
      }
      await AppSettings.instance.setBackgroundImage(bytes);
    }
  }

  Future<void> _editBackgroundImage(BuildContext context) async {
    final size = await showModalBottomSheet<_BackgroundImageSize>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose image size',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'The image is resized before saving to keep the app fast and prevent storage problems.',
              ),
              const SizedBox(height: 12),
              ..._BackgroundImageSize.values.map(
                (option) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(option.icon),
                  title: Text(option.label),
                  subtitle: Text(option.description),
                  onTap: () => Navigator.pop(sheetContext, option),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
    if (size != null && context.mounted) {
      await _pickBackgroundImage(context, size: size);
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
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.42),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant
                              .withValues(alpha: 0.45),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.wallpaper_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Background image',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    Text(
                                      settings.backgroundImage == null
                                          ? 'Optional personalization'
                                          : settings.backgroundImageEnabled
                                          ? 'Active behind your workspace'
                                          : 'Saved but currently hidden',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              if (settings.backgroundImage != null)
                                Switch(
                                  value: settings.backgroundImageEnabled,
                                  onChanged: AppSettings
                                      .instance
                                      .setBackgroundImageEnabled,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (settings.backgroundImage != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Semantics(
                                label: 'Current background image preview',
                                image: true,
                                child: SizedBox(
                                  height: 140,
                                  width: double.infinity,
                                  child: Image.memory(
                                    settings.backgroundImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Center(
                                      child: Icon(Icons.broken_image_outlined),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              height: 92,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surface,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Center(
                                child: Text('No custom image selected'),
                              ),
                            ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: () => _editBackgroundImage(context),
                                icon: Icon(
                                  settings.backgroundImage == null
                                      ? Icons.add_photo_alternate_outlined
                                      : Icons.edit_outlined,
                                ),
                                label: Text(
                                  settings.backgroundImage == null
                                      ? 'Add image'
                                      : 'Replace / resize',
                                ),
                              ),
                              if (settings.backgroundImage != null)
                                OutlinedButton.icon(
                                  onPressed: AppSettings
                                      .instance
                                      .clearBackgroundImage,
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Delete'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                    leading: const Icon(Icons.auto_awesome_outlined),
                    title: const Text('Student Life AI Assistant'),
                    subtitle: const Text('Ask about your private offline data'),
                    onTap: () => context.push(AppRoutes.assistant),
                  ),
                  ListTile(
                    leading: const Icon(Icons.school_outlined),
                    title: Text(context.tr('Grades and GPA')),
                    subtitle: const Text('Track course results and GPA'),
                    onTap: () => context.push(AppRoutes.grades),
                  ),
                  ListTile(
                    leading: const Icon(Icons.fact_check_outlined),
                    title: Text(context.tr('Attendance')),
                    subtitle: const Text('Track attendance for every class'),
                    onTap: () => context.push(AppRoutes.attendance),
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

enum _BackgroundImageSize {
  small(
    label: 'Small',
    description: '1000 x 800 px - best for older phones',
    maxWidth: 1000,
    maxHeight: 800,
    quality: 70,
    icon: Icons.photo_size_select_small_outlined,
  ),
  medium(
    label: 'Medium',
    description: '1600 x 1200 px - recommended',
    maxWidth: 1600,
    maxHeight: 1200,
    quality: 75,
    icon: Icons.photo_outlined,
  ),
  large(
    label: 'Large',
    description: '2400 x 1800 px - higher detail',
    maxWidth: 2400,
    maxHeight: 1800,
    quality: 80,
    icon: Icons.photo_size_select_large_outlined,
  );

  const _BackgroundImageSize({
    required this.label,
    required this.description,
    required this.maxWidth,
    required this.maxHeight,
    required this.quality,
    required this.icon,
  });

  final String label;
  final String description;
  final double maxWidth;
  final double maxHeight;
  final int quality;
  final IconData icon;
}

String _fontSizeLabel(double scale) {
  if (scale < 0.95) return 'Small';
  if (scale > 1.05) return 'Large';
  return 'Normal';
}
