import 'package:flutter/material.dart';

import '../data/app_settings.dart';
import '../routes/app_routes.dart';
import '../widgets/app_background.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _pageController = PageController();
  var _page = 0;

  static const _slides = [
    _WelcomeSlide(
      title: 'Student Life\nHub',
      body: 'A calm place to organize your classes, tasks, events, and budget.',
      image: true,
    ),
    _WelcomeSlide(
      title: 'Plan your week',
      body: 'Add your classes and see your upcoming routine in one clear schedule.',
      icon: Icons.calendar_month_rounded,
    ),
    _WelcomeSlide(
      title: 'Finish what matters',
      body: 'Prioritize assignments, track exams, and see your progress at a glance.',
      icon: Icons.task_alt_rounded,
    ),
    _WelcomeSlide(
      title: 'Stay in control',
      body: 'Track spending, discover events, and personalize the app to fit you.',
      icon: Icons.auto_graph_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == _slides.length - 1) {
      AppSettings.instance.completeOnboarding();
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: SafeArea(
      child: AppBackground(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemBuilder: (context, index) =>
                      _SlideView(slide: _slides[index]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _page ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _page
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (_page > 0)
                    TextButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                      ),
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox(width: 64),
                  const Spacer(),
                  FilledButton(
                    onPressed: _next,
                    child: Text(
                      _page == _slides.length - 1 ? 'Get started' : 'Next',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _WelcomeSlide {
  const _WelcomeSlide({
    required this.title,
    required this.body,
    this.icon,
    this.image = false,
  });

  final String title;
  final String body;
  final IconData? icon;
  final bool image;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _WelcomeSlide slide;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (slide.image)
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: AspectRatio(
            aspectRatio: 500 / 281,
            child: Image.asset('assets/start_page.gif', fit: BoxFit.cover),
          ),
        )
      else
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Icon(
            slide.icon,
            size: 52,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      const SizedBox(height: 28),
      Text(
        slide.title,
        style: Theme.of(context).textTheme.displaySmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 14),
      Text(
        slide.body,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ],
  );
}
