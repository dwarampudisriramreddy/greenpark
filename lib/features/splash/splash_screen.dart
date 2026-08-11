import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shell/main_shell.dart';

/// Branded splash shown at app launch: logo, wordmark and tagline, a progress
/// bar that fills while the app boots, then a soft fade into the main shell.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..forward();
    Timer(const Duration(milliseconds: 1900), _goHome);
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const MainShell(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entrance = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: entrance,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.88, end: 1.0).animate(entrance),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/icon.png',
                    width: 132,
                    height: 132,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'GREEN PARK',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 26,
                        letterSpacing: 3,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Family Restaurant',
                  style: AppText.bodySmallFor(context).copyWith(
                    fontSize: 12,
                    letterSpacing: 2.2,
                  ),
                ),
                const SizedBox(height: 30),
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) {
                    return SizedBox(
                      width: 168,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: _progressController.value,
                          minHeight: 4,
                          backgroundColor: isDark
                              ? AppColors.inkSoft
                              : AppColors.brandMint,
                          valueColor: AlwaysStoppedAnimation(
                            isDark
                                ? AppColors.accentGoldLight
                                : AppColors.brandGreen,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
