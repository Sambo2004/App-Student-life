import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'data/app_settings.dart';
import 'data/student_store.dart';
import 'routes/app_routes.dart';

const _brandSeed = Color(0xFF0F6B78);

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
      final family = settings.languageCode == 'km'
          ? 'KhmerUI'
          : settings.fontFamily == 'Default'
          ? null
          : settings.fontFamily;
      final lightTextColor = settings.highContrast
          ? Colors.black
          : settings.textColor;
      final lightScheme =
          ColorScheme.fromSeed(seedColor: _brandSeed).copyWith(
            onSurface: lightTextColor,
            onSurfaceVariant: (settings.highContrast
                    ? Colors.black
                    : settings.textColor)
                .withValues(alpha: 0.82),
          );
      final darkTextColor = settings.textColor == Colors.black87
          ? Colors.white
          : settings.textColor;
      final darkScheme =
          ColorScheme.fromSeed(
            seedColor: _brandSeed,
            brightness: Brightness.dark,
          ).copyWith(
            onSurface: settings.highContrast ? Colors.white : darkTextColor,
            onSurfaceVariant: (settings.highContrast
                    ? Colors.white
                    : darkTextColor)
                .withValues(alpha: 0.82),
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
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white.withValues(alpha: 0.96),
            indicatorColor: lightScheme.primaryContainer,
            height: 72,
            labelTextStyle: WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          navigationRailTheme: NavigationRailThemeData(
            backgroundColor: Colors.white.withValues(alpha: 0.94),
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
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(settings.fontScale)),
          child: child!,
        ),
      );
    },
  );
}
