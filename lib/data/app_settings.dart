import 'dart:convert';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends GetxController {
  AppSettings._();
  static final instance = AppSettings._();

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  String _displayName = 'Student';
  String get displayName => _displayName;
  String _fontFamily = 'Default';
  String get fontFamily => _fontFamily;
  double _fontScale = 1;
  double get fontScale => _fontScale.clamp(0.85, 1.15).toDouble();
  Color _textColor = Colors.black87;
  Color get textColor => _textColor;
  Uint8List? _backgroundImage;
  Uint8List? get backgroundImage => _backgroundImage;
  Uint8List? _profileImage;
  Uint8List? get profileImage => _profileImage;
  bool _onboardingComplete = false;
  bool get onboardingComplete => _onboardingComplete;
  String _languageCode = 'en';
  String get languageCode => _languageCode;
  bool _highContrast = false;
  bool get highContrast => _highContrast;

  Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    final savedMode = preferences.getString('themeMode');
    _onboardingComplete = preferences.getBool('onboardingComplete') ?? false;
    _languageCode = preferences.getString('languageCode') ?? 'en';
    _highContrast = preferences.getBool('highContrast') ?? false;
    _displayName = preferences.getString('displayName') ?? 'Student';
    _fontFamily = preferences.getString('fontFamily') ?? 'Default';
    _fontScale = (preferences.getDouble('fontScale') ?? 1).clamp(0.85, 1.15);
    final savedColor = preferences.getInt('textColor');
    if (savedColor != null) _textColor = Color(savedColor);
    final savedBackgroundImage = preferences.getString('backgroundImage');
    if (savedBackgroundImage != null) {
      _backgroundImage = base64Decode(savedBackgroundImage);
    }
    final savedImage = preferences.getString('profileImage');
    if (savedImage != null) _profileImage = base64Decode(savedImage);
    _themeMode = switch (savedMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    update();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    update();
    await (await SharedPreferences.getInstance()).setString(
      'themeMode',
      mode.name,
    );
  }

  Future<void> setLanguageCode(String code) async {
    if (code != 'en' && code != 'km') return;
    _languageCode = code;
    update();
    await (await SharedPreferences.getInstance()).setString('languageCode', code);
  }

  Future<void> setHighContrast(bool value) async {
    _highContrast = value;
    update();
    await (await SharedPreferences.getInstance()).setBool('highContrast', value);
  }

  Future<void> setDisplayName(String value) async {
    final name = value.trim();
    if (name.isEmpty) return;
    _displayName = name;
    update();
    await (await SharedPreferences.getInstance()).setString(
      'displayName',
      name,
    );
  }

  Future<void> setFontFamily(String family) async {
    _fontFamily = family;
    update();
    await (await SharedPreferences.getInstance()).setString(
      'fontFamily',
      family,
    );
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale.clamp(0.85, 1.15);
    update();
    await (await SharedPreferences.getInstance()).setDouble('fontScale', scale);
  }

  Future<void> setTextColor(Color color) async {
    _textColor = color;
    update();
    await (await SharedPreferences.getInstance()).setInt(
      'textColor',
      color.toARGB32(),
    );
  }

  Future<void> setBackgroundImage(Uint8List bytes) async {
    _backgroundImage = bytes;
    update();
    await (await SharedPreferences.getInstance()).setString(
      'backgroundImage',
      base64Encode(bytes),
    );
  }

  Future<void> clearBackgroundImage() async {
    _backgroundImage = null;
    update();
    await (await SharedPreferences.getInstance()).remove('backgroundImage');
  }

  Future<void> setProfileImage(Uint8List bytes) async {
    _profileImage = bytes;
    update();
    await (await SharedPreferences.getInstance()).setString(
      'profileImage',
      base64Encode(bytes),
    );
  }

  Future<void> completeOnboarding() async {
    _onboardingComplete = true;
    update();
    await (await SharedPreferences.getInstance()).setBool(
      'onboardingComplete',
      true,
    );
  }

  Future<void> reset() async {
    final preferences = await SharedPreferences.getInstance();
    for (final key in [
      'themeMode',
      'displayName',
      'fontFamily',
      'fontScale',
      'textColor',
      'backgroundImage',
      'profileImage',
      'onboardingComplete',
      'languageCode',
      'highContrast',
    ]) {
      await preferences.remove(key);
    }
    _themeMode = ThemeMode.system;
    _displayName = 'Student';
    _fontFamily = 'Default';
    _fontScale = 1;
    _textColor = Colors.black87;
    _backgroundImage = null;
    _profileImage = null;
    _onboardingComplete = false;
    _languageCode = 'en';
    _highContrast = false;
    update();
  }
}
