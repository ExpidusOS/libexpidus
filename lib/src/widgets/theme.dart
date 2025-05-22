import 'package:adwaita/adwaita.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import '../logic/method_channel.dart';

class ExpidusThemeManager extends StatefulWidget {
  const ExpidusThemeManager({
    super.key,
    this.themeMode,
    required this.child,
  });

  final ThemeMode? themeMode;
  final Widget child;

  @override
  State<ExpidusThemeManager> createState() => ExpidusThemeManagerState();
}

class ExpidusThemeManagerState extends State<ExpidusThemeManager> {
  ThemeMode get themeMode => widget.themeMode ?? ThemeMode.system;

  ColorScheme _colorSchemeFor(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ColorScheme.fromSwatch(
      brightness: brightness,
      primarySwatch: isDark
          ? const MaterialColor(0xff9aa5ce, {})
          : const MaterialColor(0xff40434f, {}),
      accentColor: isDark ? const Color(0xff7dcfff) : const Color(0xff0f4b6e),
      cardColor: isDark ? const Color(0xff161720) : const Color(0xffdadbdf),
      backgroundColor:
          isDark ? const Color(0xff1a1b26) : const Color(0xffe6e7ed),
      errorColor: isDark ? const Color(0xfff7768e) : const Color(0xff8c4351),
    );
    return base.copyWith(
      surface: base.background,
      surfaceContainer:
          Color.lerp(base.surface, base.background, isDark ? 5 : -3),
    );
  }

  ThemeData _themeFor(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? AdwaitaThemeData.dark()
        : AdwaitaThemeData.light();
    final colorScheme = _colorSchemeFor(brightness);
    return base.copyWith(
      colorScheme: colorScheme,
      primaryTextTheme: GoogleFonts.mPlus1pTextTheme(base.primaryTextTheme),
      textTheme: GoogleFonts.mPlus1pTextTheme(base.textTheme),
      typography: base.typography.copyWith(
        black: GoogleFonts.mPlus1pTextTheme(base.typography.black),
        white: GoogleFonts.mPlus1pTextTheme(base.typography.white),
        englishLike: GoogleFonts.mPlus1pTextTheme(base.typography.englishLike),
        dense: GoogleFonts.mPlus1pTextTheme(base.typography.dense),
        tall: GoogleFonts.mPlus1pTextTheme(base.typography.tall),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: colorScheme.background,
      ),
      canvasColor: colorScheme.background,
      scaffoldBackgroundColor: colorScheme.background,
      dialogTheme: base.dialogTheme.copyWith(
        backgroundColor: colorScheme.surface,
      ),
    );
  }

  Brightness _brightnessFor(BuildContext context) =>
      themeMode == ThemeMode.system
          ? MediaQuery.platformBrightnessOf(context)
          : (themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light);

  @override
  Widget build(BuildContext context) => Theme(
        data: _themeFor(_brightnessFor(context)),
        child: widget.child,
      );
}
