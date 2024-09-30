import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'headerbar.dart';

class ExpidusScaffold extends StatefulWidget {
  const ExpidusScaffold({
    super.key,
    this.scaffoldKey,
    this.title,
    this.titleWidget,
    this.onGenerateTitle,
    this.flap,
    this.flapController,
    this.flapOptions,
    this.viewSwitcher,
    this.viewSwitcherConstraint,
    this.start,
    this.end,
    this.menuItems,
    this.showActions,
    this.backgroundImage,
    required this.body,
  });

  final Key? scaffoldKey;
  final Widget? titleWidget;
  final String? title;
  final GenerateAppTitle? onGenerateTitle;
  final Widget Function(bool isDrawer)? flap;
  final FlapController? flapController;
  final FlapOptions? flapOptions;
  final Widget? viewSwitcher;
  final double? viewSwitcherConstraint;
  final List<Widget>? start;
  final List<Widget>? end;
  final List<PopupMenuEntry>? menuItems;
  final bool? showActions;
  final DecorationImage? backgroundImage;
  final Widget body;

  @override
  State<ExpidusScaffold> createState() => _ExpidusScaffoldState();
}

class _ExpidusScaffoldState extends State<ExpidusScaffold> {
  FlapController? _flapController;

  @override
  void initState() {
    super.initState();
    _flapController = widget.flapController ?? FlapController();
  }

  @override
  Widget build(BuildContext context) {
    final widgetsApp = context.findAncestorWidgetOfExactType<WidgetsApp>()!;

    final isMobile = MediaQuery.of(context).size.width <=
        (widget.viewSwitcherConstraint ?? 600);
    final isFlapVisible = widget.flap != null;
    final isViewSwitcherVisible = widget.viewSwitcher != null;

    final flap = isFlapVisible
        ? SizedBox(
            width: 200,
            child: Drawer(
              elevation: 25,
              child: widget.flap!(true),
            ),
          )
        : null;

    final onGenerateTitle =
        widget.onGenerateTitle ?? widgetsApp.onGenerateTitle;
    final title = widget.title ?? widgetsApp.title ?? '';

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          image: widget.backgroundImage,
        ),
        child: Column(
          children: [
            HeaderBar(
              titleWidget: isViewSwitcherVisible && !isMobile
                  ? widget.viewSwitcher
                  : widget.titleWidget ??
                      Text((onGenerateTitle != null
                              ? onGenerateTitle!(context)
                              : null) ??
                          title),
              end: widget.end ?? [],
              start: widget.start ?? [],
              menuItems: widget.menuItems ?? [],
              showActions: widget.showActions,
            ),
            Expanded(
              child: Scaffold(
                key: widget.scaffoldKey,
                drawerEnableOpenDragGesture: _flapController
                        ?.shouldEnableDrawerGesture(FlapPosition.start) ??
                    false,
                endDrawerEnableOpenDragGesture: _flapController
                        ?.shouldEnableDrawerGesture(FlapPosition.end) ??
                    false,
                onDrawerChanged: _flapController?.onDrawerChanged,
                drawer: flap,
                endDrawer: flap,
                body: isFlapVisible
                    ? AdwFlap(
                        flap: widget.flap!(false),
                        controller: widget.flapController,
                        options: widget.flapOptions,
                        child: widget.body,
                      )
                    : widget.body,
                bottomNavigationBar: isViewSwitcherVisible && isMobile
                    ? Container(
                        height: 51,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: context.borderColor,
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            widget.viewSwitcher!,
                          ],
                        ),
                      )
                    : null,
              ),
            )
          ],
        ),
      ),
    );
  }
}
