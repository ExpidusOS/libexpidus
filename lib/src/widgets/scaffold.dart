import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:libadwaita/libadwaita.dart' hide FlapOptions;
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'flap.dart';
import 'headerbar.dart';

typedef WrapWidgetCallback = Widget Function(
    BuildContext context, Widget child);

Widget _passthruWidgetCallback(BuildContext _, Widget child) => child;

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
    this.headerBar,
    this.headerBarPadding,
    this.showHeaderBar,
    this.showActions,
    this.wrapHeaderBar = _passthruWidgetCallback,
    this.backgroundImage,
    this.transparentBody,
    this.body,
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
  final Widget? headerBar;
  final EdgeInsetsGeometry? headerBarPadding;
  final bool? showHeaderBar;
  final bool? showActions;
  final WrapWidgetCallback wrapHeaderBar;
  final DecorationImage? backgroundImage;
  final bool? transparentBody;
  final Widget? body;

  @override
  State<ExpidusScaffold> createState() => _ExpidusScaffoldState();
}

class _ExpidusScaffoldState extends State<ExpidusScaffold> {
  FlapController? _flapController;

  @override
  void initState() {
    super.initState();
    _flapController = widget.flapController ?? FlapController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final isMobile = MediaQuery.sizeOf(context).width <=
          (widget.viewSwitcherConstraint ?? 600);
      if (isMobile && _flapController!.isOpen) {
        if (_flapController!.context != null) {
          _flapController!.close();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final widgetsApp = context.findAncestorWidgetOfExactType<WidgetsApp>()!;

    final isMobile = MediaQuery.sizeOf(context).width <=
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
          backgroundBlendMode: BlendMode.src,
          color: (widget.transparentBody ?? false)
              ? Colors.transparent
              : Theme.of(context).colorScheme.surface,
          image: widget.backgroundImage,
        ),
        child: Column(
          children: [
            if (widget.showHeaderBar ?? true)
              widget.headerBar ??
                  Padding(
                    padding: widget.headerBarPadding ?? EdgeInsets.zero,
                    child: widget.wrapHeaderBar(
                        context,
                        HeaderBar(
                          titleWidget: (isViewSwitcherVisible && !isMobile
                                  ? widget.viewSwitcher
                                  : widget.titleWidget) ??
                              Text((onGenerateTitle != null
                                      ? onGenerateTitle!(context)
                                      : null) ??
                                  title),
                          end: widget.end ?? [],
                          start: widget.start ?? [],
                          showActions: widget.showActions,
                          hasDrawer: isFlapVisible,
                          onDrawerToggle: () => _flapController!.toggle(),
                        )),
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
                backgroundColor: Colors.transparent,
                drawer: flap,
                endDrawer: flap,
                body: isFlapVisible
                    ? Flap(
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
            ),
          ],
        ),
      ),
    );
  }
}
