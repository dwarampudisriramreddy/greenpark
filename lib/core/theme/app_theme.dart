// Flutter 3.44 moved CupertinoPageTransitionsBuilder out of material.dart.
// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography system: Playfair Display for display text, Inter for UI text.
class AppText {
  AppText._();

  static TextStyle get _display => GoogleFonts.playfairDisplay();

  static TextStyle get _body => GoogleFonts.inter();

  static TextStyle get displayLarge =>
      _display.copyWith(fontSize: 34, fontWeight: FontWeight.w700, height: 1.15);

  static TextStyle get displayMedium =>
      _display.copyWith(fontSize: 27, fontWeight: FontWeight.w700, height: 1.2);

  static TextStyle get displaySmall =>
      _display.copyWith(fontSize: 21, fontWeight: FontWeight.w700, height: 1.25);

  static TextStyle get headline =>
      _body.copyWith(fontSize: 19, fontWeight: FontWeight.w700, height: 1.3);

  static TextStyle get title =>
      _body.copyWith(fontSize: 16, fontWeight: FontWeight.w600, height: 1.35);

  static TextStyle get subtitle =>
      _body.copyWith(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4, color: AppColors.inkSoft);

  static TextStyle get body =>
      _body.copyWith(fontSize: 14, fontWeight: FontWeight.w400, height: 1.55);

  static TextStyle get bodySmall =>
      _body.copyWith(fontSize: 12.5, fontWeight: FontWeight.w400, height: 1.45, color: AppColors.inkSoft);

  /// Secondary-text color that adapts to the active theme.
  static Color softColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFA8B6AD)
          : AppColors.inkSoft;

  /// Theme-aware [subtitle] — use inside widget builds.
  static TextStyle subtitleFor(BuildContext context) =>
      subtitle.copyWith(color: softColor(context));

  /// Theme-aware [bodySmall] — use inside widget builds.
  static TextStyle bodySmallFor(BuildContext context) =>
      bodySmall.copyWith(color: softColor(context));

  static TextStyle get label =>
      _body.copyWith(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6);

  static TextStyle get price =>
      _display.copyWith(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.brandGreen);
}

/// Material 3 themes (light + dark) for the whole app.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brandGreen,
      brightness: brightness,
      primary: AppColors.brandGreen,
      secondary: AppColors.accentGold,
      surface: isDark ? AppColors.paperDark : AppColors.paper,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? AppColors.paperDark : AppColors.paper,
      fontFamily: GoogleFonts.inter().fontFamily,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: AppText.displayLarge.copyWith(
          color: isDark ? AppColors.white : AppColors.ink,
        ),
        displayMedium: AppText.displayMedium.copyWith(
          color: isDark ? AppColors.white : AppColors.ink,
        ),
        displaySmall: AppText.displaySmall.copyWith(
          color: isDark ? AppColors.white : AppColors.ink,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: isDark ? AppColors.paperDark : AppColors.paper,
        foregroundColor: isDark ? AppColors.white : AppColors.ink,
        titleTextStyle: AppText.headline.copyWith(color: isDark ? AppColors.white : AppColors.ink),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? const Color(0xFF1B231E) : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide(color: isDark ? Colors.white24 : AppColors.line),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF171E1A) : AppColors.white,
        indicatorColor: isDark ? AppColors.brandGreenDark : AppColors.brandMint,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? AppColors.brandGreen
                : isDark
                    ? Colors.white54
                    : AppColors.inkSoft,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppText.label.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.brandGreen
                : isDark
                    ? Colors.white70
                    : AppColors.inkSoft,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.brandGreen,
        foregroundColor: AppColors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF2A352E) : AppColors.ink,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1B231E) : AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? Colors.white24 : AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? Colors.white24 : AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.brandGreen, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentRed),
        ),
        hintStyle: AppText.body.copyWith(
          color: isDark
              ? Colors.white54
              : AppColors.inkSoft.withValues(alpha: 0.8),
        ),
        labelStyle: AppText.body.copyWith(
          color: isDark ? Colors.white70 : AppColors.inkSoft,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white12 : AppColors.line,
        thickness: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? const Color(0xFF1B231E) : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: false,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.brandGreen,
        linearTrackColor: AppColors.brandMint,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brandGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          disabledBackgroundColor: isDark ? Colors.white12 : AppColors.line,
          disabledForegroundColor: isDark ? Colors.white38 : AppColors.inkSoft,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandGreen,
          side: const BorderSide(color: AppColors.brandGreen, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandGreen,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.brandGreen
              : null,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.brandGreen
              : null,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? const Color(0xFF1B231E) : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titleTextStyle: AppText.headline,
        contentTextStyle: AppText.body,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: isDark ? const Color(0xFF1B231E) : Colors.white,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AppColors.brandGreen,
        headerForegroundColor: Colors.white,
        todayBorder: const BorderSide(color: AppColors.brandGreen, width: 1.5),
        dayShape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
