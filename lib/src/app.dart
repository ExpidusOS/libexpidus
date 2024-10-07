import 'dart:ui';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/widgets.dart' hide runApp;

import 'logic/layering.dart';
import 'logic/method_channel.dart';

class ExpidusAppConfig {
  const ExpidusAppConfig(
    this.widget, {
    this.windowSize,
    this.windowLayer,
  });

  final Widget widget;
  final Size? windowSize;
  final ExpidusWindowLayerConfig? windowLayer;
}

void runApp(ExpidusAppConfig appConfig) {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  final methodChannel = ExpidusMethodChannel.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    if (appConfig.windowLayer != null && Platform.isLinux) {
      methodChannel.setLayering(
          appConfig.windowLayer!, appConfig.windowSize ?? const Size(0, 0));
    } else {
      appWindow!.show();
    }
  }

  runWidget(widgetsBinding.wrapWithDefaultView(appConfig.widget));
}
