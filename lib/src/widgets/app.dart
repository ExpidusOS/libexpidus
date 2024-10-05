import 'dart:io';
import 'dart:convert' show json;
import 'package:adwaita/adwaita.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'theme.dart';
import 'scaffold.dart';

enum ExpidusWindowLayer {
  background,
  bottom,
  top,
  overlay,
}

enum ExpidusWindowLayerKeyboardMode {
  none,
  exclusive,
  demand,
}

class ExpidusWindowLayerAnchor {
  const ExpidusWindowLayerAnchor({
    this.toEdge = false,
    this.margin = 0,
  });

  final bool toEdge;
  final int margin;

  dynamic toJSON() => {
        'toEdge': toEdge,
        'margin': margin,
      };

  @override
  String toString() => json.encode(toJSON());
}

class ExpidusWindowLayerConfig {
  const ExpidusWindowLayerConfig({
    this.layer = ExpidusWindowLayer.top,
    this.monitor,
    this.keyboardMode = ExpidusWindowLayerKeyboardMode.none,
    this.top = const ExpidusWindowLayerAnchor(),
    this.bottom = const ExpidusWindowLayerAnchor(),
    this.left = const ExpidusWindowLayerAnchor(),
    this.right = const ExpidusWindowLayerAnchor(),
  });

  final ExpidusWindowLayer layer;
  final String? monitor;
  final ExpidusWindowLayerKeyboardMode keyboardMode;
  final ExpidusWindowLayerAnchor top;
  final ExpidusWindowLayerAnchor bottom;
  final ExpidusWindowLayerAnchor left;
  final ExpidusWindowLayerAnchor right;

  dynamic toJSON() => {
        'layer': layer.name,
        'monitor': monitor,
        'keyboardMode': keyboardMode.name,
        'top': top.toJSON(),
        'bottom': bottom.toJSON(),
        'left': left.toJSON(),
        'right': right.toJSON(),
      };

  @override
  String toString() => json.encode(toJSON());
}

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
    this.windowLayer,
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
  final ExpidusWindowLayerConfig? windowLayer;

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
  final methodChannel = MethodChannel('expidus');
  final _appKey = GlobalKey<State<MaterialApp>>();

  ValueNotifier<bool> _hasWindowLayer = ValueNotifier(false);
  ValueNotifier<bool> get hasWindowLayer => _hasWindowLayer;

  @override
  void initState() {
    super.initState();

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

        if (widget.windowLayer != null && Platform.isLinux) {
          methodChannel.invokeMethod('setLayering', {
            ...(widget.windowLayer!.toJSON() as Map<String, dynamic>),
            'width': appWindow!.size.width,
            'height': appWindow!.size.height,
          }).then((_) {
            setState(() {
              _hasWindowLayer.value = true;
              _hasWindowLayer.notifyListeners();
            });
          });
        } else {
          appWindow!.show();
        }

        if (widget.onWindowReady != null) {
          widget.onWindowReady!();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        key: _appKey,
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
