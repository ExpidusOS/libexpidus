import 'dart:ui';
import 'package:flutter/services.dart';
import 'layering.dart';

class ExpidusMethodChannel {
  ExpidusMethodChannel._();

  factory ExpidusMethodChannel() {
    assert(_instance == null);
    _instance = ExpidusMethodChannel._();
    return instance;
  }

  final _methodChannel = const MethodChannel('expidus');
  bool _hasWindowLayer = false;

  bool get hasWindowLayer => _hasWindowLayer;

  Future<Size> setLayering(ExpidusWindowLayerConfig windowLayer,
      [Size size = const Size(0, 0)]) async {
    final value = await _methodChannel.invokeMethod('setLayering', {
      ...(windowLayer.toJSON() as Map<String, dynamic>),
      'width': size.width.toInt(),
      'height': size.height.toInt(),
    });

    _hasWindowLayer = true;
    return Size(value['width'].toDouble(), value['height'].toDouble());
  }

  Future<String> getHeaderBarLayout() => _methodChannel
      .invokeMethod<String>('getHeaderBarLayout')
      .then((value) => value!);

  Future<Map<String, dynamic>> getSystemTheme(Brightness brightness) =>
      _methodChannel
          .invokeMapMethod<String, dynamic>(
              'getSystemTheme', brightness == Brightness.dark)
          .then((value) => value!);

  static ExpidusMethodChannel? _instance;

  static ExpidusMethodChannel get instance => _instance!;

  static ExpidusMethodChannel ensureInitialized() {
    if (_instance == null) {
      ExpidusMethodChannel();
    }
    return instance;
  }
}
