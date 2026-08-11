import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shell/main_shell.dart';

/// Animated branded splash shown at app launch: the logo scales and fades in,
/// followed by the wordmark and tagline, then a soft fade into the main shell.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _fadeIn;
  late final Animation<double> _textFade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
    ).drive(Tween<double>(begin: 0.55, end: 1.0));

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ).drive(Tween<double>(begin: 0.0, end: 1.0));

    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
    ).drive(Tween<double>(begin: 0.0, end: 1.0));

    _controller.forward();
    _timer = Timer(const Duration(milliseconds: 2300), _goHome);
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const MainShell(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: _fadeIn.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/icon.png',
                          width: 124,
                          height: 124,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Opacity(
                    opacity: _textFade.value,
                    child: Column(
                      children: [
                        Text(
                          'GREEN PARK',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                fontSize: 27,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 4,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Family Restaurant',
                          style: AppText.bodySmallFor(context).copyWith(
                            fontSize: 12,
                            letterSpacing: 2.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 48,
                child: Opacity(
                  opacity: _textFade.value,
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: isDark
                          ? AppColors.accentGoldLight
                          : AppColors.brandGreen,
                      backgroundColor: isDark
                          ? AppColors.inkSoft
                          : AppColors.brandMint,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
