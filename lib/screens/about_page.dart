import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/app_shell.dart';
import '../widgets/depth_card.dart';
import '../widgets/page_header.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) => AppShell(
    index: 5,
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(context.tr('About Student Life Hub'))),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(
              children: [
                const PageHeader(
                  title: 'About us',
                  subtitle: 'A simpler way to manage student life.',
                ),
                DepthCard(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(22),
                  child: Text(
                    'Student Life Hub brings planning, study routines, campus activities, and personal budgeting together in one focused workspace. It is designed to help students spend less time organizing and more time making progress.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const _FounderHero(),
                const SizedBox(height: 20),
                _DetailsCard(
                  title: 'Founder details',
                  icon: Icons.badge_outlined,
                  children: const [
                    _InfoTile(
                      icon: Icons.person_outline,
                      title: 'Founder',
                      body: 'Sum Sambo',
                    ),
                    _InfoTile(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      body: 'sumsambo8899@gmail.com',
                    ),
                    _InfoTile(
                      icon: Icons.school_outlined,
                      title: 'Education',
                      body: 'Computer Science',
                    ),
                    _InfoTile(
                      icon: Icons.groups_outlined,
                      title: 'Team',
                      body: 'Sao Sreynet, Srun Darasthya, and Kun Korn',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _DetailsCard(
                  title: 'What guides the project',
                  icon: Icons.auto_awesome_outlined,
                  children: const [
                    _InfoTile(
                      icon: Icons.track_changes,
                      title: 'Our purpose',
                      body: 'Make everyday student planning clear, calm, and practical.',
                    ),
                    _InfoTile(
                      icon: Icons.security,
                      title: 'Privacy first',
                      body: 'Your current data stays on your device and is controlled by you.',
                    ),
                    _InfoTile(
                      icon: Icons.auto_graph,
                      title: 'Built for progress',
                      body: 'Small insights help you understand your routine and improve it.',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => DepthCard(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.fromLTRB(8, 14, 8, 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                context.tr(title),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 18),
        ...children,
      ],
    ),
  );
}

class _FounderHero extends StatefulWidget {
  const _FounderHero();

  @override
  State<_FounderHero> createState() => _FounderHeroState();
}

class _FounderHeroState extends State<_FounderHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  void _showFounderDetails() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('Meet the founder')),
        content: Text(
          context.tr(
            'Sum Sambo created Student Life Hub to make student planning clearer and more practical.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('Close')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, 18 * (1 - Curves.easeOutCubic.transform(_animation.value))),
        child: Opacity(
          opacity: _animation.value,
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: InkWell(
          onTap: _showFounderDetails,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  scheme.primary,
                  Color.lerp(scheme.primary, scheme.tertiary, 0.65)!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.28),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _AuraAvatar(color: scheme.primaryContainer),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('Founder and product builder'),
                        style: TextStyle(
                          color: scheme.onPrimary.withValues(alpha: 0.78),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('Sum Sambo'),
                        style: TextStyle(
                          color: scheme.onPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr('Building calmer tools for student life.'),
                        style: TextStyle(
                          color: scheme.onPrimary.withValues(alpha: 0.84),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: scheme.onPrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuraAvatar extends StatefulWidget {
  const _AuraAvatar({required this.color});

  final Color color;

  @override
  State<_AuraAvatar> createState() => _AuraAvatarState();
}

class _AuraAvatarState extends State<_AuraAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _pulse,
    builder: (context, _) {
      final scale = 1 + (_pulse.value * 0.06);
      return Transform.scale(
        scale: scale,
        child: Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.28),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.48),
                blurRadius: 18 + (_pulse.value * 8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/founder.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Text(
                  'SS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
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
