import 'package:flutter/material.dart';

import 'screens/languages_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/report_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_shell_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const welcome = '/welcome';
  static const main = '/main';
  static const miniMain = '/mini/main';
  static const languages = '/languages';
  static const settings = '/settings';
  static const report = '/report';

  static Map<String, WidgetBuilder> builders() => {
        splash: (_) => const SplashScreen(),
        onboarding: (_) => const OnboardingScreen(),
        welcome: (_) => const WelcomeScreen(),
        main: (_) => const MainShellScreen(),
        miniMain: (_) => const MainShellScreen(),
        languages: (_) => const LanguagesScreen(),
        settings: (_) => const SettingsScreen(),
        report: (_) => const ReportScreen(),
      };

  /// Single root route — avoids an extra “ghost” route so the home [AppBar] does not show a stray back arrow.
  static List<Route<dynamic>> initialRoutes(String initialRouteName) {
    final map = builders();
    final build = map[initialRouteName] ?? map[main]!;
    return [
      MaterialPageRoute<void>(
        builder: build,
        settings: RouteSettings(name: initialRouteName),
      ),
    ];
  }
}
