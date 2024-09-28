import 'package:adwaita/adwaita.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'theme.dart';
import 'scaffold.dart';

class ExpidusApp extends StatelessWidget {
  const ExpidusApp({
    super.key,
    this.title = '',
    this.onGenerateTitle,
    this.home,
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
  });

  final String title;
  final GenerateAppTitle? onGenerateTitle;
  final Widget? home;
  final Map<String, WidgetBuilder> routes;
  final String? initialRoute;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: title,
        onGenerateTitle: onGenerateTitle,
        home: home != null ? ExpidusThemeManager(child: home!) : null,
        routes: routes.map((k, v) =>
            MapEntry(k, (context) => ExpidusThemeManager(child: v(context)))),
        initialRoute: initialRoute,
      );
}
