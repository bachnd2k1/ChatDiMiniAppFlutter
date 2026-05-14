import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _onboardingDone = 'config_onboarding_done';
const _welcomeDone = 'config_welcome_done';
const _languageCode = 'config_language_code';
const _darkMode = 'config_dark_mode';

class AppConfigProvider extends ChangeNotifier {
  AppConfigProvider();

  SharedPreferences? _prefs;

  bool onboardingDone = false;
  bool welcomeDone = false;
  String languageCode = 'en';
  bool darkMode = false;

  Future<void> hydrate() async {
    _prefs = await SharedPreferences.getInstance();
    onboardingDone = _prefs!.getBool(_onboardingDone) ?? false;
    welcomeDone = _prefs!.getBool(_welcomeDone) ?? false;
    languageCode = _prefs!.getString(_languageCode) ?? 'en';
    darkMode = _prefs!.getBool(_darkMode) ?? false;
    notifyListeners();
  }

  Future<void> setOnboardingDone() async {
    onboardingDone = true;
    notifyListeners();
    await _prefs?.setBool(_onboardingDone, true);
  }

  Future<void> setWelcomeDone() async {
    welcomeDone = true;
    notifyListeners();
    await _prefs?.setBool(_welcomeDone, true);
  }

  Future<void> setLanguageCode(String code) async {
    languageCode = code;
    notifyListeners();
    await _prefs?.setString(_languageCode, code);
  }

  Future<void> setDarkMode(bool v) async {
    darkMode = v;
    notifyListeners();
    await _prefs?.setBool(_darkMode, v);
  }

  SplashRouteDecision nextAfterSplash() {
    if (!onboardingDone) return SplashRouteDecision.onboarding;
    if (!welcomeDone) return SplashRouteDecision.welcome;
    return SplashRouteDecision.main;
  }
}

enum SplashRouteDecision { onboarding, welcome, main }
