import 'package:flutter/material.dart';

import '../screens/welcome_page.dart';
import '../screens/home_page.dart';
import '../screens/schedule_page.dart';
import '../screens/tasks_page.dart';
import '../screens/expenses_page.dart';
import '../screens/events_page.dart';
import '../screens/profile_page.dart';
import '../screens/about_page.dart';
import '../screens/sponsors_page.dart';

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

  static final Map<String, WidgetBuilder> routes = {
    welcome: (_) => const WelcomePage(),
    home: (_) => const HomePage(),
    schedule: (_) => const SchedulePage(),
    tasks: (_) => const TasksPage(),
    expenses: (_) => const ExpensesPage(),
    events: (_) => const EventsPage(),
    profile: (_) => const ProfilePage(),
    about: (_) => const AboutPage(),
    sponsors: (_) => const SponsorsPage(),
  };
}
