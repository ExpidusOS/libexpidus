import 'package:adwaita/adwaita.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
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
    this.onWindowReady,
  });

  final String title;
  final GenerateAppTitle? onGenerateTitle;
  final List<NavigatorObserver> navigatorObservers;
  final Iterable<LocalizationsDelegate>? localizationsDelegates;
  final LocaleListResolutionCallback? localeListResolutionCallback;
  final LocaleResolutionCallback? localeResolutionCallback;
  final Iterable<Locale> supportedLocales, 
  final Widget? home;
  final Map<String, WidgetBuilder> routes;
  final String? initialRoute;
  final Alignment? windowAlignment;
  final Size? minWindowSize;
  final Size? maxWindowSize;
  final VoidCallback? onWindowReady;

  @override
  State<ExpidusApp> createState() => _ExpidusAppState();
}

class _ExpidusAppState extends State<ExpidusApp> {
  final appKey = GlobalKey<State<MaterialApp>>();

  @override
  void initState() {
    super.initState();

    doWhenWindowReady(() {
      appWindow!.title = widget.onGenerateTitle != null
          ? widget.onGenerateTitle!(appKey.currentContext!)
          : widget.title;
      appWindow!.alignment = widget.windowAlignment;
      appWindow!.minSize = widget.minWindowSize;
      appWindow!.maxSize = widget.maxWindowSize;
      appWindow!.show();

      if (widget.onWindowReady != null) {
        widget.onWindowReady!();
      }
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        key: appKey,
        title: widget.title,
        onGenerateTitle: widget.onGenerateTitle,
        navigatorObservers: widget.navigatorObservers,
        localizationsDelegates: widget.localizationsDelegates,
        localeListResolutionCallback: widget.localeListResolutionCallback,
        localeResolutionCallback: widget.localeResolutionCallback,
        supportedLocales: widget.supportedLocales,
        home: widget.home != null
            ? ExpidusThemeManager(child: widget.home!)
            : null,
        routes: widget.routes.map((k, v) =>
            MapEntry(k, (context) => ExpidusThemeManager(child: v(context)))),
        initialRoute: widget.initialRoute,
      );
}
