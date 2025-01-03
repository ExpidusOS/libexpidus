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
  ThemeData? _system;

  ThemeMode get themeMode =>
      widget.themeMode ?? ThemeMode.light;

  ThemeData _fallbackFor(Brightness brightness) => brightness == Brightness.dark
      ? AdwaitaThemeData.dark()
      : AdwaitaThemeData.light();

  Brightness _brightnessFor(BuildContext context) =>
      themeMode == ThemeMode.system
          ? MediaQuery.platformBrightnessOf(context)
          : (themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light);

  @override
  void initState() {
    super.initState();

    getSystemTheme().then((themeData) {
      setState(() {
        _system = themeData;
      });
    }).catchError((exception, stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: exception,
        stack: stack,
        library: 'expidus',
        context: ErrorDescription('getSystemTheme'),
      ));
    });
  }

  Color _fromMap(Map<String, int> values) =>
      Color.fromARGB(values['A']!, values['R']!, values['G']!, values['B']!);

  Color? _decode(dynamic value) =>
      value == null ? null : _fromMap(value.cast<String, int>());

  Future<ThemeData> getSystemTheme() async {
    final data = await ExpidusMethodChannel.instance.getSystemTheme();
    final brightness = data['dark'] ? Brightness.dark : Brightness.light;
    final fb = _fallbackFor(brightness);

    final colorScheme = ColorScheme(
      primary:
          _decode(data['colorScheme']['primary']) ?? fb.colorScheme.primary,
      onPrimary:
          _decode(data['colorScheme']['onPrimary']) ?? fb.colorScheme.onPrimary,
      secondary:
          _decode(data['colorScheme']['secondary']) ?? fb.colorScheme.secondary,
      onSecondary: _decode(data['colorScheme']['onSecondary']) ??
          fb.colorScheme.onSecondary,
      error: _decode(data['colorScheme']['error']) ?? fb.colorScheme.error,
      onError:
          _decode(data['colorScheme']['onError']) ?? fb.colorScheme.onError,
      surface:
          _decode(data['colorScheme']['surface']) ?? fb.colorScheme.surface,
      onSurface:
          _decode(data['colorScheme']['onSurface']) ?? fb.colorScheme.onSurface,
      outline: _decode(data['colorScheme']['outline']),
      brightness: brightness,
    );

    final textTheme = TextTheme(
      displayLarge: GoogleFonts.mPlus1p(
        color: _decode(data['text']['color']) ?? fb.textTheme.displayLarge!.color,
        fontSize: 57,
      ),
      displayMedium: GoogleFonts.mPlus1p(
        color: _decode(data['text']['color']) ?? fb.textTheme.displayMedium!.color,
        fontSize: 45,
      ),
      displaySmall: GoogleFonts.mPlus1p(
        color: _decode(data['text']['color']) ?? fb.textTheme.displaySmall!.color,
        fontSize: 36,
      ),
      headlineLarge: GoogleFonts.mPlus1p(
        color: _decode(data['text']['color']) ?? fb.textTheme.headlineLarge!.color,
        fontSize: 32,
        fontStyle: FontStyle.italic,
      ),
      headlineMedium: GoogleFonts.mPlus1p(
        color: _decode(data['text']['color']) ?? fb.textTheme.headlineMedium!.color,
        fontSize: 28,
        fontStyle: FontStyle.italic,
      ),
      headlineSmall: GoogleFonts.mPlus1p(
        color: _decode(data['text']['color']) ?? fb.textTheme.headlineSmall!.color,
        fontSize: 24,
        fontStyle: FontStyle.italic,
      ),
      titleLarge: GoogleFonts.mPlus1p(
        color: _decode(data['text']['color']) ?? fb.textTheme.titleLarge!.color,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: GoogleFonts.mPlus1p(
        color: _decode(data['text']['color']) ?? fb.textTheme.titleMedium!.color,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: GoogleFonts.mPlus1p(
        color: _decode(data['text']['color']) ?? fb.textTheme.titleSmall!.color,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: GoogleFonts.mPlus1p(
        color: _decode(data['text']['color']) ?? fb.textTheme.bodyLarge!.color,
        fontSize: 17,
      ),
      bodyMedium: GoogleFonts.mPlus1p(
        color: _decode(data['text']['color']) ?? fb.textTheme.bodyMedium!.color,
        fontSize: 15,
      ),
      bodySmall: GoogleFonts.mPlus1p(
        color: _decode(data['text']['color']) ?? fb.textTheme.bodySmall!.color,
        fontSize: 12,
      ),
      labelLarge: GoogleFonts.mPlus1p(
        color: _decode(data['text']['color']) ?? fb.textTheme.labelLarge!.color,
        fontSize: 16,
      ),
      labelMedium: GoogleFonts.mPlus1p(
        color: _decode(data['text']['color']) ?? fb.textTheme.labelMedium!.color,
        fontSize: 14,
      ),
      labelSmall: GoogleFonts.mPlus1p(
        color: _decode(data['text']['color']) ?? fb.textTheme.labelSmall!.color,
        fontSize: 12,
      ),
    );

    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: _decode(data['appBar']['background']) ?? fb.appBarTheme.backgroundColor,
        foregroundColor: _decode(data['appBar']['foreground']) ?? fb.appBarTheme.foregroundColor,
        shadowColor: _decode(data['appBar']['shadow']) ?? fb.appBarTheme.shadowColor,
        shape: Border.all(
            width: 1.0,
            color: _decode(data['appBar']['border']) ?? Colors.black),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: _decode(data['colorScheme']['accent']),
        colorScheme: colorScheme.copyWith(
            primary: _decode(data['colorScheme']['accent']),
            onPrimary: _decode(data['colorScheme']['onAccent'])),
        padding: const EdgeInsets.all(6.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: _system ??
            _fallbackFor(_brightnessFor(context)),
        child: widget.child,
      );
}
