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
      final page = isWide
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: child,
              ),
            )
          : child;

    void navigate(int value) {
      if (value != index) {
        // Replace only the current tab route and let GetX animate the change.
        // This avoids the abrupt browser-like replacement animation.
        context.go(destinations[value]);
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: AppBackground(
          child: isWide
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: index,
                      onDestinationSelected: navigate,
                      labelType: NavigationRailLabelType.all,
                      minWidth: 88,
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
                    Expanded(child: page),
                  ],
                )
              : page,
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
