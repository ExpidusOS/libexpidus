import 'dart:io';
import 'package:adwaita/adwaita.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import '../logic/method_channel.dart';
import 'theme.dart';
import 'scaffold.dart';

class ExpidusApp extends StatefulWidget {
  const ExpidusApp({
    super.key,
    this.title = '',
    this.onGenerateTitle,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.home,
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.windowAlignment,
    this.minWindowSize,
    this.maxWindowSize,
    this.windowSize,
    this.onWindowReady,
    this.themeMode,
  });

  final String title;
  final GenerateAppTitle? onGenerateTitle;
  final List<NavigatorObserver> navigatorObservers;
  final Iterable<LocalizationsDelegate>? localizationsDelegates;
  final LocaleListResolutionCallback? localeListResolutionCallback;
  final LocaleResolutionCallback? localeResolutionCallback;
  final Iterable<Locale> supportedLocales;
  final Widget? home;
  final Map<String, WidgetBuilder> routes;
  final String? initialRoute;
  final Alignment? windowAlignment;
  final Size? minWindowSize;
  final Size? maxWindowSize;
  final Size? windowSize;
  final VoidCallback? onWindowReady;
  final ThemeMode? themeMode;

  @override
  State<ExpidusApp> createState() => ExpidusAppState();

  static ExpidusAppState? maybeOf(BuildContext context) {
    ExpidusAppState? app;

    if (context is StatefulElement && context.state is ExpidusAppState) {
      app = context.state as ExpidusAppState;
    }

    return context.findRootAncestorStateOfType<ExpidusAppState>() ?? app;
  }

  static ExpidusAppState of(BuildContext context) => maybeOf(context)!;
  static bool hasWindowLayer(BuildContext context) =>
      of(context).hasWindowLayer.value;
}

class ExpidusAppState extends State<ExpidusApp> {
  final _appKey = GlobalKey<State<MaterialApp>>();

  ValueNotifier<bool> _hasWindowLayer = ValueNotifier(false);
  ValueNotifier<bool> get hasWindowLayer => _hasWindowLayer;

  @override
  void initState() {
    super.initState();

    final methodChannel = ExpidusMethodChannel.ensureInitialized();
    _hasWindowLayer.value = methodChannel.hasWindowLayer;
    _hasWindowLayer.notifyListeners();

    if (!kIsWeb &&
        !Platform.isIOS &&
        !Platform.isAndroid &&
        !Platform.isFuchsia) {
      doWhenWindowReady(() {
        appWindow!.title = widget.onGenerateTitle != null
            ? widget.onGenerateTitle!(_appKey.currentContext!)
            : widget.title;
        appWindow!.alignment = widget.windowAlignment;
        appWindow!.minSize = widget.minWindowSize;
        appWindow!.maxSize = widget.maxWindowSize;

        if (widget.windowSize != null) {
          appWindow!.size = widget.windowSize!;
        }

        if (widget.onWindowReady != null) {
          widget.onWindowReady!();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => ExpidusThemeManager(
        themeMode: widget.themeMode,
        child: Builder(
          builder: (context) => MaterialApp(
            key: _appKey,
            title: widget.title,
            onGenerateTitle: widget.onGenerateTitle,
            navigatorObservers: widget.navigatorObservers,
            localizationsDelegates: widget.localizationsDelegates,
            localeListResolutionCallback: widget.localeListResolutionCallback,
            localeResolutionCallback: widget.localeResolutionCallback,
            supportedLocales: widget.supportedLocales,
            home: widget.home,
            routes: widget.routes,
            initialRoute: widget.initialRoute,
            themeMode: widget.themeMode,
            theme: Theme.of(context),
            darkTheme: Theme.of(context),
          ),
        ),
      );
}
