import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'data/app_settings.dart';
import 'data/student_store.dart';
import 'routes/app_routes.dart';
import 'services/error_reporter.dart';
import 'services/local_notification_service.dart';

const _brandSeed = Color(0xFF172B4D);
const _lightAppBackground = Color(0xFFF6F8FC);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ErrorReporter.instance.initialize();
  try {
    await Future.wait([
      AppSettings.instance.initialize(),
      StudentStore.instance.initialize(),
    ]).timeout(const Duration(seconds: 8));
  } catch (error, stack) {
    // Start with safe defaults if local storage is unavailable or slow.
    await ErrorReporter.instance.record(error, stack);
  }
  runApp(const StudentLifeApp());
  unawaited(_initializeBackgroundServices());
}

Future<void> _initializeBackgroundServices() async {
  try {
    await LocalNotificationService.instance
        .initialize()
        .timeout(const Duration(seconds: 5));
    await LocalNotificationService.instance
        .syncTasks(StudentStore.instance.tasks)
        .timeout(const Duration(seconds: 5));
  } catch (_) {
    // A notification plugin failure must not block the app UI.
  }
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
      final family = settings.languageCode == 'km'
          ? 'KhmerUI'
          : settings.fontFamily == 'Default'
          ? null
          : settings.fontFamily;
      final lightTextColor = settings.highContrast ? Colors.black : Colors.black87;
      final lightScheme =
          ColorScheme.fromSeed(seedColor: _brandSeed).copyWith(
            onSurface: lightTextColor,
            onSurfaceVariant: lightTextColor.withValues(alpha: 0.82),
          );
      const darkTextColor = Colors.white;
      final darkScheme =
          ColorScheme.fromSeed(
            seedColor: _brandSeed,
            brightness: Brightness.dark,
          ).copyWith(
            onSurface: settings.highContrast ? Colors.white : darkTextColor,
            onSurfaceVariant: darkTextColor.withValues(alpha: 0.82),
          );
      return MaterialApp.router(
        title: 'Student Life Hub',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        locale: Locale(settings.languageCode),
        supportedLocales: const [Locale('en'), Locale('km')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightScheme,
          scaffoldBackgroundColor: _lightAppBackground,
          cardTheme: CardThemeData(
            clipBehavior: Clip.antiAlias,
            elevation: 1,
            shadowColor: const Color(0x1F172B4D),
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: ButtonStyle(
              minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              textStyle: WidgetStatePropertyAll(
                TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.1),
              ),
              elevation: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.pressed) ? 0 : 1,
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              animationDuration: const Duration(milliseconds: 180),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: BorderSide(color: lightScheme.outline),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          chipTheme: ChipThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          ),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 12,
          ),
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            insetPadding: const EdgeInsets.all(16),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: _lightAppBackground.withValues(alpha: 0.96),
            indicatorColor: lightScheme.primaryContainer,
            height: 72,
            labelTextStyle: WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          navigationRailTheme: NavigationRailThemeData(
            backgroundColor: _lightAppBackground.withValues(alpha: 0.94),
            indicatorColor: lightScheme.primaryContainer,
            groupAlignment: -0.7,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: lightScheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: lightScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            showDragHandle: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
          ),
          textTheme: Typography.material2021().black.apply(
            fontFamily: family,
            bodyColor: lightTextColor,
            displayColor: lightTextColor,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkScheme,
          scaffoldBackgroundColor: const Color(0xFF121212),
          cardTheme: CardThemeData(
            clipBehavior: Clip.antiAlias,
            elevation: 1,
            shadowColor: Colors.black54,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: ButtonStyle(
              minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              textStyle: const WidgetStatePropertyAll(
                TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.1),
              ),
              elevation: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.pressed) ? 0 : 1,
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              animationDuration: const Duration(milliseconds: 180),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: BorderSide(color: darkScheme.outline),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          chipTheme: ChipThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          ),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 12,
          ),
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            insetPadding: const EdgeInsets.all(16),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: const Color(0xFF181A1D),
            indicatorColor: darkScheme.primaryContainer,
            height: 72,
            labelTextStyle: const WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          navigationRailTheme: NavigationRailThemeData(
            backgroundColor: const Color(0xFF181A1D),
            indicatorColor: darkScheme.primaryContainer,
            groupAlignment: -0.7,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: darkScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: darkScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            showDragHandle: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
          ),
          textTheme: Typography.material2021().white.apply(
            fontFamily: family,
            bodyColor: darkTextColor,
            displayColor: darkTextColor,
          ),
        ),
        themeMode: AppSettings.instance.themeMode,
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          // Preserve Android/iOS accessibility text size and apply the
          // optional in-app adjustment on top of it.
          final deviceScale = mediaQuery.textScaler.scale(1);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(
                deviceScale * settings.fontScale,
              ),
            ),
            child: child!,
          );
        },
      );
    },
  );
}
