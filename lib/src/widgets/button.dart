import 'package:flutter/material.dart' hide Button;

/// Set of status that a [Button] widget can be at any given time.
enum ButtonStatus { enabled, active, enabledHovered, activeHovered, tapDown }

typedef ButtonColorBuilder = Color? Function(
  BuildContext,
  Color? backgroundColor,
  ButtonStatus, {
  bool opaque,
});

typedef ButtonWidgetBuilder = Widget Function(
  BuildContext,
  ButtonStatus,
  Widget?,
);

const String _bothBuilderAndChildError = """
Either use builder or use child, Both can't be assigned at one""";

class Button extends StatefulWidget {
  const Button({
    super.key,
    this.padding = defaultButtonPadding,
    this.margin = EdgeInsets.zero,
    this.builder,
    this.child,
    this.textStyle,
    this.onPressed,
    this.opaque = false,
    this.backgroundColor,
    this.backgroundColorBuilder = defaultBackgroundColorBuilder,
    this.constraints = defaultButtonConstrains,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(6),
    ),
    this.border,
    this.shape = BoxShape.rectangle,
    this.boxShadow,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeOutQuad,
    this.isActive = false,
  }) : assert(
          builder != null || child != null,
          _bothBuilderAndChildError,
        );

  Button.circular({
    super.key,
    double size = 34,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.builder,
    this.child,
    this.textStyle,
    this.onPressed,
    this.opaque = false,
    this.backgroundColor,
    this.backgroundColorBuilder = defaultBackgroundColorBuilder,
    this.border,
    this.boxShadow,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeOutQuad,
    this.isActive = false,
  })  : assert(builder != null || child != null, _bothBuilderAndChildError),
        constraints = BoxConstraints.tightFor(width: size, height: size),
        shape = BoxShape.circle,
        borderRadius = null;

  const Button.pill({
    super.key,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 32),
    this.margin = EdgeInsets.zero,
    this.builder,
    this.child,
    this.textStyle,
    this.onPressed,
    this.opaque = false,
    this.backgroundColor,
    this.backgroundColorBuilder = defaultBackgroundColorBuilder,
    this.constraints = defaultButtonConstrains,
    this.border,
    this.boxShadow,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeOutQuad,
    this.isActive = false,
  })  : borderRadius = const BorderRadius.all(
          Radius.circular(9999),
        ),
        shape = BoxShape.rectangle,
        assert(builder != null || child != null, _bothBuilderAndChildError);

  const Button.flat({
    super.key,
    this.padding = defaultButtonPadding,
    this.margin = EdgeInsets.zero,
    this.builder,
    this.child,
    this.textStyle,
    this.onPressed,
    this.backgroundColor,
    this.backgroundColorBuilder = flatBackgroundColorBuilder,
    this.constraints = defaultButtonConstrains,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(6),
    ),
    this.border,
    this.shape = BoxShape.rectangle,
    this.boxShadow,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeOutQuad,
    this.isActive = false,
  })  : opaque = false,
        assert(builder != null || child != null, _bothBuilderAndChildError);

  static const defaultButtonConstrains = BoxConstraints(
    minHeight: 24,
    minWidth: 16,
  );

  static const defaultButtonPadding = EdgeInsets.symmetric(
    vertical: 8,
    horizontal: 17,
  );

  /// Empty space to inscribe inside the [BoxDecoration].
  ///  The [child], if any, is placed inside this padding.
  final EdgeInsetsGeometry padding;

  /// Empty space to surround the [BoxDecoration] and [child].
  final EdgeInsetsGeometry margin;

  /// Builder function used to create the child widget inside
  /// the button widget.
  ///
  /// You can get the [child] parameter using this build method.
  final ButtonWidgetBuilder? builder;

  /// Widget that will be rendered inside this button.
  final Widget? child;

  /// Action to perform when the widget is tapped.
  final VoidCallback? onPressed;

  /// Whether the [Button] has some tranparaceny or
  /// is it fully opaque
  final bool opaque;

  /// The backgroundColor of the [Button].
  /// This is then passed to [backgroundColorBuilder]
  /// to build this button for different [ButtonStatus]
  final Color? backgroundColor;

  /// Builder function used to create the background color of the button widget.
  final ButtonColorBuilder? backgroundColorBuilder;

  /// Additional constraints to apply to the child.
  ///
  /// The [padding] goes inside the constraints.
  final BoxConstraints? constraints;

  /// If non-null, the corners of this box are rounded by this [BorderRadius].
  ///
  /// Applies only to boxes with rectangular shapes; ignored if [shape] is not
  /// [BoxShape.rectangle].
  ///
  /// {@macro flutter.painting.BoxDecoration.clip}
  final BorderRadius? borderRadius;

  /// A border to draw above the background color.
  ///
  /// Follows the [shape] and [borderRadius].
  ///
  /// Use [Border] objects to describe borders that do not depend on the reading
  /// direction.
  ///
  /// Use [BoxBorder] objects to describe borders that should flip their left
  /// and right edges based on whether the text is being read left-to-right or
  /// right-to-left.
  ///
  final BoxBorder? border;

  /// Default text style applied to the child widget.
  final TextStyle? textStyle;

  /// The shape to fill the background color into and
  /// to cast as the [boxShadow].
  ///
  /// If this is [BoxShape.circle] then [borderRadius] is ignored.
  ///
  /// The [shape] cannot be interpolated; animating between two [BoxDecoration]s
  /// with different [shape]s will result in a discontinuity in the rendering.
  /// To interpolate between two shapes, consider using [ShapeDecoration] and
  /// different [ShapeBorder]s; in particular, [CircleBorder] instead of
  /// [BoxShape.circle] and [RoundedRectangleBorder] instead of
  /// [BoxShape.rectangle].
  ///
  /// {@macro flutter.painting.BoxDecoration.clip}
  final BoxShape shape;

  /// A list of shadows cast by this box behind the box.
  ///
  /// The shadow follows the [shape] of the box.
  final List<BoxShadow>? boxShadow;

  /// The duration over which to animate the parameters of this container.
  final Duration animationDuration;

  /// The curve to apply when animating the parameters of this container.
  final Curve animationCurve;

  /// Status flag to denote that the widget is active.
  /// Usually for popup buttons.
  final bool isActive;

  static Color? defaultBackgroundColorBuilder(
    BuildContext context,
    Color? backgroundColor,
    ButtonStatus status, {
    bool opaque = false,
  }) {
    if (status == ButtonStatus.enabled) {
      return null;
    }
    return (backgroundColor ??
            Theme.of(context).buttonTheme?.colorScheme?.primary ??
            Theme.of(context).colorScheme!.primary!)
        .resolveDefaultButtonColor(
      context,
      status,
      opaque: opaque,
    );
  }

  static Color? flatBackgroundColorBuilder(
    BuildContext context,
    Color? backgroundColor,
    ButtonStatus status, {
    bool opaque = false,
  }) {
    return (backgroundColor ??
            Theme.of(context).buttonTheme?.colorScheme?.primary! ??
            Theme.of(context).colorScheme!.primary!)
        .resolveFlatButtonColor(
      context,
      status,
      opaque: opaque,
    );
  }

  @override
  State<StatefulWidget> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  late ButtonStatus _status;

  @override
  void initState() {
    super.initState();
    _status = widget.isActive ? ButtonStatus.active : ButtonStatus.enabled;
  }

  @override
  void didUpdateWidget(covariant Button oldWidget) {
    super.didUpdateWidget(oldWidget);
    reset();
  }

  void reset() {
    if (_status == ButtonStatus.tapDown) {
      _status = widget.isActive
          ? ButtonStatus.activeHovered
          : ButtonStatus.enabledHovered;
    } else {
      _status = widget.isActive ? ButtonStatus.active : ButtonStatus.enabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin
          .add(Theme.of(context).buttonTheme?.padding ?? EdgeInsets.zero),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(
          () => _status = widget.isActive
              ? ButtonStatus.activeHovered
              : ButtonStatus.enabledHovered,
        ),
        onExit: (_) => setState(
          () => _status =
              widget.isActive ? ButtonStatus.active : ButtonStatus.enabled,
        ),
        child: GestureDetector(
          onTap: widget.onPressed,
          onTapDown: (_) => setState(() => _status = ButtonStatus.tapDown),
          onTapUp: (_) => setState(reset),
          onTapCancel: () => setState(() => _status = ButtonStatus.enabled),
          child: AnimatedContainer(
            padding: widget.padding,
            constraints: widget.constraints,
            duration: widget.animationDuration,
            curve: widget.animationCurve,
            decoration: BoxDecoration(
              border: widget.border,
              shape: widget.shape,
              boxShadow: widget.boxShadow,
              borderRadius: widget.borderRadius,
              color: widget.backgroundColorBuilder?.call(
                context,
                widget.backgroundColor,
                _status,
                opaque: widget.opaque,
              ),
            ),
            child: DefaultTextStyle.merge(
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.6,
              ).merge(widget.textStyle),
              child: widget.child ??
                  widget.builder!(
                    context,
                    _status,
                    widget.child,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

extension _ButtonBackgroundColor on Color {
  Color? resolveDefaultButtonColor(
    BuildContext context,
    ButtonStatus status, {
    bool opaque = false,
  }) {
    final isDark = Theme.of(context).colorScheme.brightness == Brightness.dark;
    if (opaque) {
      switch (status) {
        case ButtonStatus.enabled:
          return withOpacity(1);
        case ButtonStatus.enabledHovered:
          return withOpacity(isDark ? 0.85 : 0.88);
        case ButtonStatus.active:
          return withOpacity(isDark ? 0.80 : 0.84);
        case ButtonStatus.activeHovered:
          return withOpacity(isDark ? 0.76 : 0.80);
        case ButtonStatus.tapDown:
          return withOpacity(isDark ? 0.75 : 0.80);
      }
    } else {
      switch (status) {
        case ButtonStatus.enabled:
          return withOpacity(isDark ? 0.10 : 0.08);
        case ButtonStatus.enabledHovered:
          return withOpacity(isDark ? 0.15 : 0.12);
        case ButtonStatus.active:
          return withOpacity(isDark ? 0.20 : 0.16);
        case ButtonStatus.activeHovered:
          return withOpacity(isDark ? 0.24 : 0.20);
        case ButtonStatus.tapDown:
          return withOpacity(isDark ? 0.25 : 0.20);
      }
    }
  }

  Color? resolveFlatButtonColor(
    BuildContext context,
    ButtonStatus status, {
    bool opaque = false,
  }) {
    final isDark = Theme.of(context).colorScheme.brightness == Brightness.dark;
    switch (status) {
      case ButtonStatus.enabledHovered:
        return withOpacity(isDark ? 0.07 : 0.056);
      case ButtonStatus.active:
        return withOpacity(isDark ? 0.10 : 0.08);
      case ButtonStatus.activeHovered:
        return withOpacity(isDark ? 0.13 : 0.105);
      case ButtonStatus.tapDown:
        return withOpacity(isDark ? 0.19 : 0.128);
      case ButtonStatus.enabled:
        return null;
    }
  }
}
