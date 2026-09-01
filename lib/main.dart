import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'data/app_settings.dart';
import 'data/student_store.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    AppSettings.instance.initialize(),
    StudentStore.instance.initialize(),
  ]);
  runApp(const StudentLifeApp());
}

class StudentLifeApp extends StatefulWidget {
  const StudentLifeApp({super.key});

  @override
  State<StudentLifeApp> createState() => _StudentLifeAppState();
}

class _StudentLifeAppState extends State<StudentLifeApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Keep the router alive while settings rebuild the app theme.
    _router = AppRoutes.createRouter();
  }

  @override
  Widget build(BuildContext context) => GetBuilder<AppSettings>(
    init: AppSettings.instance,
    builder: (settings) {
      final family = settings.fontFamily == 'Default'
          ? null
          : settings.fontFamily;
      final lightScheme =
          ColorScheme.fromSeed(seedColor: const Color(0xFF5B5CE2)).copyWith(
            onSurface: settings.textColor,
            onSurfaceVariant: settings.textColor.withValues(alpha: 0.72),
          );
      final darkTextColor = settings.textColor == Colors.black87
          ? Colors.white
          : settings.textColor;
      final darkScheme =
          ColorScheme.fromSeed(
            seedColor: const Color(0xFF5B5CE2),
            brightness: Brightness.dark,
          ).copyWith(
            onSurface: darkTextColor,
            onSurfaceVariant: darkTextColor.withValues(alpha: 0.72),
          );
      return MaterialApp.router(
        title: 'Student Life Hub',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightScheme,
          scaffoldBackgroundColor: Colors.white,
          navigationBarTheme: const NavigationBarThemeData(
            backgroundColor: Colors.white,
          ),
          textTheme: Typography.material2021().black.apply(
            fontFamily: family,
            bodyColor: settings.textColor,
            displayColor: settings.textColor,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkScheme,
          scaffoldBackgroundColor: const Color(0xFF121212),
          textTheme: Typography.material2021().white.apply(
            fontFamily: family,
            bodyColor: darkTextColor,
            displayColor: darkTextColor,
          ),
        ),
        themeMode: AppSettings.instance.themeMode,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(settings.fontScale)),
          child: child!,
        ),
      );
    },
  );
}
