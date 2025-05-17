import 'package:flutter/material.dart';
import 'package:libadwaita/src/animations/slide_hide.dart';
import 'package:libadwaita/src/controllers/flap_controller.dart';
import 'package:libadwaita/src/internal/window_resize_listener.dart';
import 'package:libadwaita/src/widgets/adw/flap.dart'
    show FoldPolicy, FlapPosition;

class FlapOptions {
  const FlapOptions({
    this.foldPolicy = FoldPolicy.auto,
    this.flapPosition = FlapPosition.start,
    this.visible = true,
    this.listenResize = true,
  });

  /// The FoldPolicy of this flap, defaults to auto
  final FoldPolicy foldPolicy;

  /// The FlapPosition of this flap, defaults to start
  final FlapPosition flapPosition;

  /// The visiblity of this flap, defaults to true
  final bool visible;

  final bool listenResize;
}

class Flap extends StatefulWidget {
  const Flap({
    super.key,
    required this.flap,
    required this.child,
    this.width = 290.0,
    this.viewSwitcherConstraint = 650.0,
    this.separator,
    this.controller,
    FlapOptions? options,
  }) : options = options ?? const FlapOptions();

  /// The flap widget itself, Mainly is a `Sidebar` instance
  final Widget flap;

  /// The content of the page
  final Widget? child;

  final Widget? separator;

  final double width;
  final double viewSwitcherConstraint;

  /// The options for this flap
  final FlapOptions options;

  /// The controller for this flap
  final FlapController? controller;

  @override
  _FlapState createState() => _FlapState();
}

class _FlapState extends State<Flap> {
  late FlapController _controller;

  void rebuild() => setState(() {});

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _controller = FlapController();
    } else {
      _controller = widget.controller!;
    }

    _controller.addListener(rebuild);
    updateFlapData();
    _controller.context = context;

    if (!widget.options.visible) widget.controller?.close();
  }

  void updateFlapData() {
    _controller
      ..policy = widget.options.foldPolicy
      ..position = widget.options.flapPosition;
  }

  @override
  void didUpdateWidget(covariant Flap oldWidget) {
    updateFlapData();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.removeListener(rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // probably shouldn;t do this but no one is looking :P
    _controller.context = context;

    final content = widget.child != null
        ? Expanded(
            child: widget.child!,
          )
        : null;

    final flap = SlideHide(
      isHidden: _controller.shouldHide(),
      width: widget.width,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: widget.flap,
      ),
    );

    final separator = widget.separator ?? const Divider();

    final children = [flap, separator, if (content != null) content!];

    final finalChildren = widget.options.flapPosition == FlapPosition.start
        ? children
        : children.reversed.toList();

    Widget value = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: finalChildren,
    );

    if (widget.options.listenResize) {
      value = WindowResizeListener(
        onResize: (Size size) =>
            WidgetsBinding.instance.addPostFrameCallback((_) {
          // The stuff that happens when the window is resized
          // We check for the mobile state and update it on every resize
          // Do nothin if FoldPolicy is never / always, because they are not
          // affected by window resizes.
          // If FoldPolicy is auto, then close / open the sidebar depending on the
          // state
          final isMobile = size.width < widget.viewSwitcherConstraint;
          _controller.updateModalState(context, state: isMobile);
          if (!widget.options.visible) return;
          switch (widget.options.foldPolicy) {
            case FoldPolicy.never:
            case FoldPolicy.always:
              break;
            case FoldPolicy.auto:
              _controller.updateOpenState(state: !isMobile);
              break;
          }
        }),
        child: value,
      );
    }

    return value;
  }
}
