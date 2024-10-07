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
  ThemeData? _systemDark;
  ThemeData? _systemLight;

  ThemeMode get themeMode => widget.themeMode ?? ThemeMode.light;

  bool get _hasSystemColorSchemes =>
      _systemDark != null || _systemLight != null;

  ThemeData? get system =>
      themeMode == ThemeMode.dark ? _systemDark : _systemLight;
  ThemeData get fallback => themeMode == ThemeMode.dark
      ? AdwaitaThemeData.dark()
      : AdwaitaThemeData.light();
  ThemeData get data => system ?? fallback;

  @override
  void initState() {
    super.initState();

    getSystemTheme(Brightness.light).then((themeData) {
      setState(() {
        _systemLight = themeData;
      });
    });

    getSystemTheme(Brightness.dark).then((themeData) {
      setState(() {
        _systemLight = themeData;
      });
    });
  }

  Color _fromMap(Map<String, int> values) =>
      Color.fromARGB(values['A']!, values['R']!, values['G']!, values['B']!);

  Future<ThemeData> getSystemTheme(Brightness brightness) async {
    final data = await ExpidusMethodChannel.instance.getSystemTheme(brightness);

    final colorScheme = ColorScheme(
      primary: _fromMap(data['colorScheme']['primary'].cast<String, int>()),
      onPrimary: _fromMap(data['colorScheme']['onPrimary'].cast<String, int>()),
      secondary: _fromMap(data['colorScheme']['secondary'].cast<String, int>()),
      onSecondary:
          _fromMap(data['colorScheme']['onSecondary'].cast<String, int>()),
      error: _fromMap(data['colorScheme']['error'].cast<String, int>()),
      onError: _fromMap(data['colorScheme']['onError'].cast<String, int>()),
      surface: _fromMap(data['colorScheme']['surface'].cast<String, int>()),
      onSurface: _fromMap(data['colorScheme']['onSurface'].cast<String, int>()),
      outline: _fromMap(data['colorScheme']['outline'].cast<String, int>()),
      brightness: brightness,
    );

    final textTheme = TextTheme(
      displayLarge: GoogleFonts.mPlus1p(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 57,
      ),
      displayMedium: GoogleFonts.mPlus1p(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 45,
      ),
      displaySmall: GoogleFonts.mPlus1p(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 36,
      ),
      headlineLarge: GoogleFonts.mPlus1p(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 32,
        fontStyle: FontStyle.italic,
      ),
      headlineMedium: GoogleFonts.mPlus1p(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 28,
        fontStyle: FontStyle.italic,
      ),
      headlineSmall: GoogleFonts.mPlus1p(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 24,
        fontStyle: FontStyle.italic,
      ),
      titleLarge: GoogleFonts.mPlus1p(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: GoogleFonts.mPlus1p(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: GoogleFonts.mPlus1p(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: GoogleFonts.mPlus1p(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 17,
      ),
      bodyMedium: GoogleFonts.mPlus1p(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 15,
      ),
      bodySmall: GoogleFonts.mPlus1p(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 12,
      ),
      labelLarge: GoogleFonts.mPlus1p(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 16,
      ),
      labelMedium: GoogleFonts.mPlus1p(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 14,
      ),
      labelSmall: GoogleFonts.mPlus1p(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 12,
      ),
    );

    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor:
            _fromMap(data['appBar']['background'].cast<String, int>()),
        foregroundColor:
            _fromMap(data['appBar']['foreground'].cast<String, int>()),
        shadowColor: _fromMap(data['appBar']['shadow'].cast<String, int>()),
        shape: Border.all(
            width: 1.0,
            color: _fromMap(data['appBar']['border'].cast<String, int>())),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor:
            _fromMap(data['colorScheme']['accent'].cast<String, int>()),
        colorScheme: colorScheme.copyWith(
            primary:
                _fromMap(data['colorScheme']['accent'].cast<String, int>()),
            onPrimary:
                _fromMap(data['colorScheme']['onAccent'].cast<String, int>())),
        padding: const EdgeInsets.all(6.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: data,
        child: widget.child,
      );
}
