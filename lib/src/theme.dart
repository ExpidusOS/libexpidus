import 'package:adwaita/adwaita.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';

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
  static final _methodChannel = MethodChannel('expidus');

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
    final data = await _methodChannel.invokeMethod(
        'getSystemTheme', brightness == Brightness.dark);

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
      displayLarge: TextStyle(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 57,
      ),
      displayMedium: TextStyle(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 45,
      ),
      displaySmall: TextStyle(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 36,
      ),
      headlineLarge: TextStyle(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 32,
      ),
      headlineMedium: TextStyle(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 28,
      ),
      headlineSmall: TextStyle(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 24,
      ),
      titleLarge: TextStyle(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 22,
      ),
      titleMedium: TextStyle(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 16,
      ),
      titleSmall: TextStyle(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 14,
      ),
      bodyLarge: TextStyle(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 14,
      ),
      bodyMedium: TextStyle(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 12,
      ),
      bodySmall: TextStyle(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 11,
      ),
      labelLarge: TextStyle(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 16,
      ),
      labelMedium: TextStyle(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 14,
      ),
      labelSmall: TextStyle(
        color: _fromMap(data['text']['color'].cast<String, int>()),
        fontSize: 12,
      ),
    );

    return ThemeData(
      applyElevationOverlayColor: false,
      fontFamily: data['text']['font'],
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor:
            _fromMap(data['appBar']['background'].cast<String, int>()),
        foregroundColor:
            _fromMap(data['appBar']['foreground'].cast<String, int>()),
        shadowColor: _fromMap(data['appBar']['shadow'].cast<String, int>()),
        shape: Border.all(
            width: 2.0,
            color: _fromMap(data['appBar']['border'].cast<String, int>())),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: data,
        child: widget.child,
      );
}
