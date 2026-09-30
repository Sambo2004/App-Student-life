import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/app_settings.dart';
import '../l10n/app_localizations.dart';
import '../routes/app_routes.dart';

const _learningNavy = Color(0xFF172B4D);
const _learningBlue = Color(0xFF2E6BFF);
const _learningSurface = Color(0xFFF6F8FC);

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _controller = PageController();
  var _page = 0;

  static const _steps = [
    _LearningStep(
      icon: Icons.dashboard_customize_rounded,
      accent: _learningBlue,
      eyebrow: 'ONE PLACE FOR STUDENT LIFE',
      title: 'Organize your week',
      description: 'See your classes, deadlines, events, and priorities in one clear view.',
      items: ['Schedule classes and events', 'Keep every deadline visible'],
    ),
    _LearningStep(
      icon: Icons.insights_rounded,
      accent: Color(0xFF0F8B8D),
      eyebrow: 'SEE YOUR PROGRESS',
      title: 'Stay in control',
      description: 'Manage tasks and expenses while charts help you understand your routine.',
      items: ['Track tasks and spending', 'Review progress with charts'],
    ),
    _LearningStep(
      icon: Icons.lock_rounded,
      accent: Color(0xFF7B61FF),
      eyebrow: 'PRIVATE AND PERSONAL',
      title: 'Your student life, your way',
      description: 'Keep your information on your device and personalize the app for your routine.',
      items: ['Back up and restore your data', 'Customize language and appearance'],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == _steps.length - 1) {
      AppSettings.instance.completeOnboarding();
      context.go(AppRoutes.home);
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 760;
    return Scaffold(
      backgroundColor: _learningSurface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 56 : 20,
                vertical: isWide ? 32 : 18,
              ),
              child: Column(
                children: [
                  _TopBar(page: _page, total: _steps.length),
                  const SizedBox(height: 20),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _steps.length,
                      onPageChanged: (value) => setState(() => _page = value),
                      itemBuilder: (context, index) => _LearningSlide(
                        step: _steps[index],
                        active: index == _page,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ProgressDots(current: _page, total: _steps.length),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      if (_page > 0)
                        TextButton(
                          onPressed: () => _controller.previousPage(
                            duration: const Duration(milliseconds: 360),
                            curve: Curves.easeOutCubic,
                          ),
                          child: Text(context.tr('Back')),
                        )
                      else
                        const SizedBox(width: 72),
                      const Spacer(),
                      FilledButton(
                        onPressed: _next,
                        style: FilledButton.styleFrom(
                          backgroundColor: _learningNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          context.tr(
                            _page == _steps.length - 1
                                ? 'Get started'
                                : 'Next',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.page, required this.total});

  final int page;
  final int total;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _learningNavy,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.auto_stories_rounded, color: Colors.white),
      ),
      const SizedBox(width: 12),
      Text(
        context.tr('Student Life Hub'),
        style: const TextStyle(
          color: _learningNavy,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      const Spacer(),
      Text(
        '${page + 1} / $total',
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _LearningStep {
  const _LearningStep({
    required this.icon,
    required this.accent,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.items,
  });

  final IconData icon;
  final Color accent;
  final String eyebrow;
  final String title;
  final String description;
  final List<String> items;
}

class _LearningSlide extends StatefulWidget {
  const _LearningSlide({required this.step, required this.active});

  final _LearningStep step;
  final bool active;

  @override
  State<_LearningSlide> createState() => _LearningSlideState();
}

class _LearningSlideState extends State<_LearningSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  )..forward();

  @override
  void didUpdateWidget(covariant _LearningSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _animation
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 760;
    final step = widget.step;
    return FadeTransition(
      opacity: CurvedAnimation(parent: _animation, curve: Curves.easeOut),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: _LearningCopy(step: step)),
                  const SizedBox(width: 72),
                  Expanded(child: _CoursePreview(step: step)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LearningCopy(step: step),
                  const SizedBox(height: 28),
                  _CoursePreview(step: step),
                ],
              ),
      ),
    );
  }
}

class _LearningCopy extends StatelessWidget {
  const _LearningCopy({required this.step});

  final _LearningStep step;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.tr(step.eyebrow),
        style: TextStyle(
          color: step.accent,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.4,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        context.tr(step.title),
        style: const TextStyle(
          color: _learningNavy,
          fontSize: 42,
          fontWeight: FontWeight.w900,
          height: 1.08,
          letterSpacing: -1,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        context.tr(step.description),
        style: const TextStyle(
          color: Color(0xFF53627A),
          fontSize: 17,
          height: 1.5,
        ),
      ),
    ],
  );
}

class _CoursePreview extends StatelessWidget {
  const _CoursePreview({required this.step});

  final _LearningStep step;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE4E9F2)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14172B4D),
          blurRadius: 24,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: step.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(step.icon, color: step.accent, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                context.tr('Your student dashboard'),
                style: const TextStyle(
                  color: _learningNavy,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: 0.42,
            minHeight: 9,
            color: step.accent,
            backgroundColor: const Color(0xFFE9EDF4),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          context.tr('Your routine, one clear view.'),
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 18),
        for (final item in step.items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 19, color: step.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.tr(item),
                    style: const TextStyle(
                      color: _learningNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 14),
        Row(
          children: [
            const Icon(Icons.lock_outline, size: 17, color: Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text(
              context.tr('Offline and private'),
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      total,
      (index) => AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: current == index ? 28 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: current == index ? _learningBlue : const Color(0xFFD4DCE8),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
