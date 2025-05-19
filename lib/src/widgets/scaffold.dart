import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:libadwaita/libadwaita.dart' hide FlapOptions;
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'dispatch_nav_observer.dart';
import 'flap.dart';
import 'headerbar.dart';

typedef WrapWidgetCallback = Widget Function(
    BuildContext context, Widget child);

Widget _passthruWidgetCallback(BuildContext _, Widget child) => child;

class ExpidusScaffold extends StatefulWidget {
  ExpidusScaffold({
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
    this.initialRoute,
    this.onUnknownRoute,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.navigatorObservers,
    this.routes = const <String, WidgetBuilder>{},
    this.navigatorKey,
    this.onRouteChanged,
  })  : assert(
          body == null || onGenerateInitialRoutes == null,
          'If onGenerateInitialRoutes is specified, the home argument will be '
          'redundant.',
        ),
        assert(
          body == null || !routes.containsKey(Navigator.defaultRouteName),
          'If the body property is specified, the routes table '
          'cannot include an entry for "/", since it would be redundant.',
        );

  final Key? scaffoldKey;
  final Widget? titleWidget;
  final String? title;
  final GenerateAppTitle? onGenerateTitle;
  final Widget Function(NavigatorState nav, bool isDrawer)? flap;
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
  final Map<String, WidgetBuilder> routes;
  final RouteFactory? onUnknownRoute;
  final RouteFactory? onGenerateRoute;
  final String? initialRoute;
  final InitialRouteListFactory? onGenerateInitialRoutes;
  final List<NavigatorObserver>? navigatorObservers;
  final GlobalKey<NavigatorState>? navigatorKey;
  final void Function(Route? route)? onRouteChanged;

  @override
  State<ExpidusScaffold> createState() => _ExpidusScaffoldState();
}

class _ExpidusScaffoldState extends State<ExpidusScaffold> {
  FlapController? _flapController;
  GlobalKey<NavigatorState> _navigator = GlobalKey();
  Route? _currentRoute;

  GlobalKey<NavigatorState> get navigator => widget.navigatorKey ?? _navigator;

  String get _initialRouteName =>
      WidgetsBinding.instance.platformDispatcher.defaultRouteName !=
              Navigator.defaultRouteName
          ? WidgetsBinding.instance.platformDispatcher.defaultRouteName
          : widget.initialRoute ??
              WidgetsBinding.instance.platformDispatcher.defaultRouteName;

  void _routeChanged(Route? value) {
    _currentRoute = value;
    if (widget.onRouteChanged != null) {
      widget.onRouteChanged!(value);
    }

    // NOTE: Ugly hack to make the menu button rebuild.
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final String? name = settings.name;
    final WidgetBuilder? pageContentBuilder =
        name == Navigator.defaultRouteName && widget.body != null
            ? (BuildContext context) => widget.body!
            : widget.routes![name];

    Route? value;
    if (pageContentBuilder != null) {
      value = MaterialPageRoute<dynamic>(
          settings: settings, builder: pageContentBuilder);
    } else if (widget.onGenerateRoute != null) {
      value = widget.onGenerateRoute!(settings);
    } else {
      value = null;
    }
    return value;
  }

  Route<dynamic> _onUnknownRoute(RouteSettings settings) {
    assert(() {
      if (widget.onUnknownRoute == null) {
        throw FlutterError(
          'Could not find a generator for route $settings in the $runtimeType.\n'
          'Make sure your root app widget has provided a way to generate \n'
          'this route.\n'
          'Generators for routes are searched for in the following order:\n'
          ' 1. For the "/" route, the "home" property, if non-null, is used.\n'
          ' 2. Otherwise, the "routes" table is used, if it has an entry for '
          'the route.\n'
          ' 3. Otherwise, onGenerateRoute is called. It should return a '
          'non-null value for any valid route not handled by "home" and "routes".\n'
          ' 4. Finally if all else fails onUnknownRoute is called.\n'
          'Unfortunately, onUnknownRoute was not set.',
        );
      }
      return true;
    }());
    final Route<dynamic>? result = widget.onUnknownRoute!(settings);
    assert(() {
      if (result == null) {
        throw FlutterError(
          'The onUnknownRoute callback returned null.\n'
          'When the $runtimeType requested the route $settings from its '
          'onUnknownRoute callback, the callback returned null. Such callbacks '
          'must never return null.',
        );
      }
      return true;
    }());
    return result!;
  }

  Widget? _buildFlap(bool isDrawer) => navigator.currentState != null
      ? widget.flap!(navigator.currentState!, isDrawer)
      : null;

  @override
  void initState() {
    super.initState();
    _flapController = widget.flapController ?? FlapController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final isMobile = MediaQuery.sizeOf(context).width <=
          (widget.viewSwitcherConstraint ?? 650);
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
        (widget.viewSwitcherConstraint ?? 650);
    final isFlapVisible = widget.flap != null;
    final isViewSwitcherVisible = widget.viewSwitcher != null;

    final flap = isFlapVisible
        ? Padding(
            padding: const EdgeInsets.all(8),
            child: Drawer(
              width: double.infinity,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 25,
              child: _buildFlap(true),
            ),
          )
        : null;

    final onGenerateTitle =
        widget.onGenerateTitle ?? widgetsApp.onGenerateTitle;
    final title = widget.title ?? widgetsApp.title ?? '';

    Widget body = Navigator(
      clipBehavior: Clip.none,
      restorationScopeId: 'nav',
      key: navigator,
      initialRoute: _initialRouteName,
      onGenerateRoute: _onGenerateRoute,
      onGenerateInitialRoutes: widget.onGenerateInitialRoutes == null
          ? Navigator.defaultGenerateInitialRoutes
          : (NavigatorState navigator, String initialRouteName) {
              return widget.onGenerateInitialRoutes!(initialRouteName);
            },
      onUnknownRoute: _onUnknownRoute,
      observers: [
        DispatchNavigatorObserver(
          onChangeTop: (top, _) => _routeChanged(top),
          onPush: (route, _) => _routeChanged(route),
          onPop: (route, _) => _routeChanged(route),
        ),
        ...(widget.navigatorObservers ?? []),
      ],
      routeTraversalEdgeBehavior: kIsWeb
          ? TraversalEdgeBehavior.leaveFlutterView
          : TraversalEdgeBehavior.parentScope,
      reportsRouteUpdateToEngine: true,
    );

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
                          onBackPressed: () {
                            if (navigator.currentState != null) {
                              navigator.currentState!.maybePop();
                            }
                          },
                          route: _currentRoute,
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
                        flap: Padding(
                          padding: const EdgeInsets.all(8),
                          child: _buildFlap(false),
                        ),
                        controller: widget.flapController,
                        options: widget.flapOptions,
                        viewSwitcherConstraint:
                            widget.viewSwitcherConstraint ?? 650.0,
                        child: body,
                      )
                    : body,
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
