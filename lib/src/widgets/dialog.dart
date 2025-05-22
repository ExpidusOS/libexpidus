import 'package:flutter/material.dart' as material;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_core/libadwaita_core.dart';

class DialogPage extends StatelessWidget {
  const DialogPage({
    super.key,
    this.title,
    this.titleWidget,
    this.child,
    this.onClose,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? child;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool useCloseButton =
        parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AdwHeaderBar(
          start: [
            if (parentRoute?.impliesAppBarDismissal ?? false && !useCloseButton)
              material.BackButton(
                onPressed: () {
                  Navigator.maybePop(context);
                },
              ),
          ],
          title: titleWidget ?? (title != null ? Text(title!) : null),
          actions: AdwActions(
            onClose: onClose,
          ),
          style: const HeaderBarStyle(
            autoPositionWindowButtons: false,
            isTransparent: true,
          ),
        ),
        Flexible(
          child: child ?? const SizedBox(),
        ),
      ],
    );
  }
}

class Dialog extends StatelessWidget {
  const Dialog({
    super.key,
    this.initialRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    this.onGenerateRoute,
    this.routes = const <String, WidgetBuilder>{},
    this.home,
    this.navigatorObservers,
  });

  final String? initialRoute;
  final InitialRouteListFactory? onGenerateInitialRoutes;
  final Map<String, WidgetBuilder> routes;
  final RouteFactory? onUnknownRoute;
  final RouteFactory? onGenerateRoute;
  final Widget? home;
  final List<NavigatorObserver>? navigatorObservers;

  String get _initialRouteName =>
      WidgetsBinding.instance.platformDispatcher.defaultRouteName !=
              Navigator.defaultRouteName
          ? WidgetsBinding.instance.platformDispatcher.defaultRouteName
          : initialRoute ??
              WidgetsBinding.instance.platformDispatcher.defaultRouteName;

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final String? name = settings.name;
    final WidgetBuilder? pageContentBuilder =
        name == Navigator.defaultRouteName && home != null
            ? (BuildContext context) => home!
            : routes![name];

    Route? value;
    if (pageContentBuilder != null) {
      value = material.MaterialPageRoute<dynamic>(
          settings: settings, builder: pageContentBuilder);
    } else if (onGenerateRoute != null) {
      value = onGenerateRoute!(settings);
    } else {
      value = null;
    }
    return value;
  }

  Route<dynamic> _onUnknownRoute(RouteSettings settings) {
    assert(() {
      if (onUnknownRoute == null) {
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
    final Route<dynamic>? result = onUnknownRoute!(settings);
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

  @override
  Widget build(BuildContext context) => material.Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Navigator(
            clipBehavior: Clip.none,
            initialRoute: _initialRouteName,
            onGenerateRoute: _onGenerateRoute,
            onGenerateInitialRoutes: onGenerateInitialRoutes == null
                ? Navigator.defaultGenerateInitialRoutes
                : (NavigatorState navigator, String initialRouteName) {
                    return onGenerateInitialRoutes!(initialRouteName);
                  },
            onUnknownRoute: _onUnknownRoute,
            observers: navigatorObservers ?? [],
            routeTraversalEdgeBehavior: kIsWeb
                ? TraversalEdgeBehavior.leaveFlutterView
                : TraversalEdgeBehavior.parentScope,
          ),
        ),
      );
}
