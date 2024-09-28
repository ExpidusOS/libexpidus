import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';

class ExpidusScaffold extends StatelessWidget {
  const ExpidusScaffold({
    super.key,
    this.scaffoldKey,
    this.title,
    this.onGenerateTitle,
    this.flap,
    this.flapController,
    this.flapOptions,
    this.viewSwitcher,
    this.viewSwitcherConstraint,
    this.start,
    this.end,
    required this.body,
  });

  final Key? scaffoldKey;
  final String? title;
  final GenerateAppTitle? onGenerateTitle;
  final Widget Function(bool isDrawer)? flap;
  final FlapController? flapController;
  final FlapOptions? flapOptions;
  final Widget? viewSwitcher;
  final double? viewSwitcherConstraint;
  final List<Widget>? start;
  final List<Widget>? end;
  final Widget body;

  bool get _showActions =>
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows;

  @override
  Widget build(BuildContext context) {
    final widgetsApp = context.findAncestorWidgetOfExactType<WidgetsApp>()!;

    final onGenerateTitle = this.onGenerateTitle ?? widgetsApp.onGenerateTitle;
    final title = this.title ?? widgetsApp.title;

    return AdwScaffold(
      scaffoldKey: scaffoldKey,
      actions: AdwActions().bitsdojo,
      controls: _showActions ? null : AdwControls(),
      title: Text(onGenerateTitle != null ? onGenerateTitle!(context) : title),
      flap: flap,
      flapController: flapController,
      flapOptions: flapOptions,
      viewSwitcher: viewSwitcher,
      viewSwitcherConstraint: viewSwitcherConstraint,
      start: start,
      end: end,
      body: body,
    );
  }
}
