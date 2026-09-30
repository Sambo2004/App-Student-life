import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores a small local diagnostic record. It never sends student data online.
class ErrorReporter {
  ErrorReporter._();

  static final instance = ErrorReporter._();

  static const _lastErrorKey = 'lastError';

  Future<void> initialize() async {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      unawaited(record(details.exception, details.stack ?? StackTrace.empty));
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(record(error, stack));
      return true;
    };
  }

  Future<void> record(Object error, StackTrace stack) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        _lastErrorKey,
        '${DateTime.now().toIso8601String()}\n$error\n$stack',
      );
    } catch (_) {
      // Diagnostics must never cause a second failure.
    }
  }

  Future<String?> readLastError() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_lastErrorKey);
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_lastErrorKey);
  }
}
