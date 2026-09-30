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
  Uint8List? _backgroundImage;
  Uint8List? get backgroundImage => _backgroundImage;
  bool _backgroundImageEnabled = true;
  bool get backgroundImageEnabled => _backgroundImageEnabled;
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
    _fontScale = (preferences.getDouble('fontScale') ?? 1)
        .clamp(0.85, 1.15)
        .toDouble();
    final savedBackgroundImage = preferences.getString('backgroundImage');
    if (savedBackgroundImage != null) {
      _backgroundImage = _decodeBytes(savedBackgroundImage);
    }
    _backgroundImageEnabled =
        preferences.getBool('backgroundImageEnabled') ?? true;
    final savedImage = preferences.getString('profileImage');
    if (savedImage != null) _profileImage = _decodeBytes(savedImage);
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
    final safeScale = scale.clamp(0.85, 1.15).toDouble();
    _fontScale = safeScale;
    update();
    await (await SharedPreferences.getInstance()).setDouble(
      'fontScale',
      safeScale,
    );
  }

  Future<void> setBackgroundImage(Uint8List bytes) async {
    _backgroundImage = bytes;
    _backgroundImageEnabled = true;
    update();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('backgroundImage', base64Encode(bytes));
    await preferences.setBool('backgroundImageEnabled', true);
  }

  Future<void> setBackgroundImageEnabled(bool value) async {
    if (_backgroundImage == null && value) return;
    _backgroundImageEnabled = value;
    update();
    await (await SharedPreferences.getInstance()).setBool(
      'backgroundImageEnabled',
      value,
    );
  }

  Future<void> clearBackgroundImage() async {
    _backgroundImage = null;
    _backgroundImageEnabled = true;
    update();
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('backgroundImage');
    await preferences.remove('backgroundImageEnabled');
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
      'backgroundImage',
      'backgroundImageEnabled',
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
    _backgroundImage = null;
    _backgroundImageEnabled = true;
    _profileImage = null;
    _onboardingComplete = false;
    _languageCode = 'en';
    _highContrast = false;
    update();
  }

  Uint8List? _decodeBytes(String value) {
    try {
      return base64Decode(value);
    } on FormatException {
      return null;
    }
  }
}
