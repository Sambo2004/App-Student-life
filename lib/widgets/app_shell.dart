import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/app_settings.dart';
import '../l10n/app_localizations.dart';
import '../routes/app_routes.dart';
import 'app_background.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.index, required this.child});
  final int index;
  final Widget child;

  static const destinations = [
    AppRoutes.home,
    AppRoutes.schedule,
    AppRoutes.tasks,
    AppRoutes.expenses,
    AppRoutes.events,
    AppRoutes.profile,
  ];

  static List<NavigationDestination> navigationDestinationsFor(
    BuildContext context,
  ) {
    final labels = const [
      'Home',
      'Schedule',
      'Tasks',
      'Budget',
      'Events',
      'Profile',
    ].map(context.tr).toList();
    return [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: labels[0],
      ),
      NavigationDestination(
        icon: const Icon(Icons.calendar_month_outlined),
        selectedIcon: const Icon(Icons.calendar_month),
        label: labels[1],
      ),
      NavigationDestination(
        icon: const Icon(Icons.task_alt_outlined),
        selectedIcon: const Icon(Icons.task_alt),
        label: labels[2],
      ),
      NavigationDestination(
        icon: const Icon(Icons.wallet_outlined),
        selectedIcon: const Icon(Icons.wallet),
        label: labels[3],
      ),
      NavigationDestination(
        icon: const Icon(Icons.event_outlined),
        selectedIcon: const Icon(Icons.event),
        label: labels[4],
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline),
        selectedIcon: const Icon(Icons.person),
        label: labels[5],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: AppSettings.instance,
    builder: (context, _) {
      final navigationDestinations = navigationDestinationsFor(
        context,
      );
      final isWide = MediaQuery.sizeOf(context).width >= 700;
      final isExpandedRail = MediaQuery.sizeOf(context).width >= 1100;
      final page = isWide
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: _PageEntrance(child: child),
              ),
            )
          : _PageEntrance(child: child);
      final animatedPage = AnimatedSwitcher(
        duration: const Duration(milliseconds: 360),
        reverseDuration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.025, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(child.key ?? child.runtimeType),
          child: page,
        ),
      );

    void navigate(int value) {
      if (value != index) {
        // Replace only the current tab route and keep the transition in GoRouter.
        context.go(destinations[value]);
      } else {
        // A second tap on the active tab returns that page to its top.
        context.go(
          '${destinations[value]}?top=${DateTime.now().microsecondsSinceEpoch}',
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: _SwipeNavigation(
          index: index,
          onNavigate: navigate,
          child: AppBackground(
            child: isWide
                ? Row(
                    children: [
                      NavigationRail(
                        leading: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 18, 0, 28),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.school_rounded,
                                  color: Colors.white,
                                  size: 19,
                                ),
                              ),
                              if (isExpandedRail) ...[
                                const SizedBox(width: 10),
                                Text(
                                  'Student Life',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ],
                          ),
                        ),
                        selectedIndex: index,
                        onDestinationSelected: navigate,
                        labelType: isExpandedRail
                            ? NavigationRailLabelType.none
                            : NavigationRailLabelType.all,
                        extended: isExpandedRail,
                        minExtendedWidth: 196,
                        minWidth: 76,
                        useIndicator: true,
                        destinations: navigationDestinations
                            .map(
                              (destination) => NavigationRailDestination(
                                icon: destination.icon,
                                selectedIcon: destination.selectedIcon,
                                label: Text(destination.label),
                              ),
                            )
                            .toList(),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: animatedPage),
                    ],
                  )
                : animatedPage,
          ),
        ),
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: navigate,
              labelBehavior:
                  NavigationDestinationLabelBehavior.alwaysShow,
              destinations: navigationDestinations,
            ),
    );
    },
  );
}

class _SwipeNavigation extends StatelessWidget {
  const _SwipeNavigation({
    required this.index,
    required this.onNavigate,
    required this.child,
  });

  final int index;
  final ValueChanged<int> onNavigate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var distance = 0.0;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) => distance = 0,
      onHorizontalDragUpdate: (details) {
        distance += details.primaryDelta ?? 0;
      },
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        final movedEnough = distance.abs() >= 56;
        final flickedEnough = velocity.abs() >= 350;
        if (!movedEnough && !flickedEnough) {
          distance = 0;
          return;
        }

        if (distance < 0 || velocity < -350) {
          if (index < AppShell.destinations.length - 1) {
            onNavigate(index + 1);
          }
        } else if (index > 0) {
          onNavigate(index - 1);
        }
        distance = 0;
      },
      child: child,
    );
  }
}

class _PageEntrance extends StatelessWidget {
  const _PageEntrance({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: const Duration(milliseconds: 480),
    curve: Curves.easeOutCubic,
    builder: (context, value, child) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 18 * (1 - value)),
        child: Transform.scale(
          scale: 0.985 + (value * 0.015),
          alignment: Alignment.topCenter,
          child: child,
        ),
      ),
    ),
    child: child,
  );
}
