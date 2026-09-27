import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/app_settings.dart';
import '../screens/about_page.dart';
import '../screens/events_page.dart';
import '../screens/expenses_page.dart';
import '../screens/home_page.dart';
import '../screens/grades_page.dart';
import '../screens/profile_page.dart';
import '../screens/planner_page.dart';
import '../screens/pomodoro_page.dart';
import '../screens/weekly_report_page.dart';
import '../screens/schedule_page.dart';
import '../screens/sponsors_page.dart';
import '../screens/study_streak_page.dart';
import '../screens/backup_restore_page.dart';
import '../screens/tasks_page.dart';
import '../screens/welcome_page.dart';

abstract final class AppRoutes {
  static const welcome = '/';
  static const home = '/home';
  static const schedule = '/schedule';
  static const tasks = '/tasks';
  static const expenses = '/expenses';
  static const events = '/events';
  static const profile = '/profile';
  static const about = '/about';
  static const sponsors = '/sponsors';
  static const planner = '/planner';
  static const pomodoro = '/pomodoro';
  static const grades = '/grades';
  static const weeklyReport = '/weekly-report';
  static const studyStreak = '/study-streak';
  static const backupRestore = '/backup-restore';

  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: AppSettings.instance.onboardingComplete ? home : welcome,
      redirect: (context, state) {
        final onboardingComplete = AppSettings.instance.onboardingComplete;
        final isWelcome = state.matchedLocation == welcome;
        if (!onboardingComplete && !isWelcome) return welcome;
        if (onboardingComplete && isWelcome) return home;
        return null;
      },
      routes: [
        GoRoute(
          path: welcome,
          pageBuilder: (_, state) => _page(state, const WelcomePage()),
        ),
        GoRoute(
          path: home,
          pageBuilder: (_, state) => _page(state, const HomePage()),
        ),
        GoRoute(
          path: schedule,
          pageBuilder: (_, state) => _page(state, const SchedulePage()),
        ),
        GoRoute(
          path: tasks,
          pageBuilder: (_, state) => _page(state, const TasksPage()),
        ),
        GoRoute(
          path: expenses,
          pageBuilder: (_, state) => _page(state, const ExpensesPage()),
        ),
        GoRoute(
          path: events,
          pageBuilder: (_, state) => _page(state, const EventsPage()),
        ),
        GoRoute(
          path: profile,
          pageBuilder: (_, state) => _page(state, const ProfilePage()),
        ),
        GoRoute(
          path: about,
          pageBuilder: (_, state) => _page(state, const AboutPage()),
        ),
        GoRoute(
          path: sponsors,
          pageBuilder: (_, state) => _page(state, const SponsorsPage()),
        ),
        GoRoute(
          path: planner,
          pageBuilder: (_, state) => _page(state, const PlannerPage()),
        ),
        GoRoute(
          path: pomodoro,
          pageBuilder: (_, state) => _page(state, const PomodoroPage()),
        ),
        GoRoute(
          path: grades,
          pageBuilder: (_, state) => _page(state, const GradesPage()),
        ),
        GoRoute(
          path: weeklyReport,
          pageBuilder: (_, state) => _page(state, const WeeklyReportPage()),
        ),
        GoRoute(
          path: studyStreak,
          pageBuilder: (_, state) => _page(state, const StudyStreakPage()),
        ),
        GoRoute(
          path: backupRestore,
          pageBuilder: (_, state) => _page(state, const BackupRestorePage()),
        ),
      ],
      errorBuilder: (_, state) =>
          Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
    );
  }

  static CustomTransitionPage<void> _page(GoRouterState state, Widget child) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 160),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.015, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
