import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_router.dart';
import '../providers/app_config_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _continue());
  }

  Future<void> _continue() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final cfg = context.read<AppConfigProvider>();
    switch (cfg.nextAfterSplash()) {
      case SplashRouteDecision.onboarding:
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
        break;
      case SplashRouteDecision.welcome:
        Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
        break;
      case SplashRouteDecision.main:
        Navigator.of(context).pushReplacementNamed(AppRoutes.main);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
