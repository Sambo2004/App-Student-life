import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  static const navigationDestinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month),
      label: 'Schedule',
    ),
    NavigationDestination(
      icon: Icon(Icons.task_alt_outlined),
      selectedIcon: Icon(Icons.task_alt),
      label: 'Tasks',
    ),
    NavigationDestination(
      icon: Icon(Icons.wallet_outlined),
      selectedIcon: Icon(Icons.wallet),
      label: 'Budget',
    ),
    NavigationDestination(
      icon: Icon(Icons.event_outlined),
      selectedIcon: Icon(Icons.event),
      label: 'Events',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 700;

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
                    Expanded(child: child),
                  ],
                )
              : child,
        ),
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: navigate,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              destinations: navigationDestinations,
            ),
    );
  }
}
