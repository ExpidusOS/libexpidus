import 'package:flutter/material.dart';

class DispatchNavigatorObserver extends NavigatorObserver {
  DispatchNavigatorObserver({
    this.onChangeTop,
    this.onPop,
    this.onPush,
    this.onRemove,
    this.onReplace,
    this.onStartUserGesture,
    this.onStopUserGesture,
  });

  final void Function(Route topRoute, Route? previousTopRoute)? onChangeTop;
  final void Function(Route<dynamic> route, Route<dynamic>? previousRoute)?
      onPop;
  final void Function(Route<dynamic> route, Route<dynamic>? previousRoute)?
      onPush;
  final void Function(Route<dynamic> route, Route<dynamic>? previousRoute)?
      onRemove;
  final void Function({Route<dynamic>? newRoute, Route<dynamic>? oldRoute})?
      onReplace;
  final void Function(Route<dynamic> route, Route<dynamic>? previousRoute)?
      onStartUserGesture;
  final VoidCallback? onStopUserGesture;

  void didChangeTop(Route topRoute, Route? previousTopRoute) {
    if (onChangeTop != null) onChangeTop!(topRoute, previousTopRoute);
  }

  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (onPop != null) onPop!(route, previousRoute);
  }

  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (onPush != null) onPush!(route, previousRoute);
  }

  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (onRemove != null) onRemove!(route, previousRoute);
  }

  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (onReplace != null) onReplace!(newRoute: newRoute, oldRoute: oldRoute);
  }

  void didStartUserGesture(
      Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (onStartUserGesture != null) onStartUserGesture!(route, previousRoute);
  }

  void didStopUserGesture() {
    if (onStopUserGesture != null) onStopUserGesture!();
  }
}
