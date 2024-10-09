import 'dart:convert' show json;

enum ExpidusWindowLayer {
  background,
  bottom,
  top,
  overlay,
}

enum ExpidusWindowLayerKeyboardMode {
  none,
  exclusive,
  demand,
}

class ExpidusWindowLayerAnchor {
  const ExpidusWindowLayerAnchor({
    this.toEdge = false,
    this.margin = 0,
  });

  final bool toEdge;
  final int margin;

  dynamic toJSON() => {
        'toEdge': toEdge,
        'margin': margin,
      };

  @override
  String toString() => json.encode(toJSON());
}

class ExpidusWindowLayerConfig {
  const ExpidusWindowLayerConfig({
    this.layer = ExpidusWindowLayer.top,
    this.monitor,
    this.autoExclusiveZone = false,
    this.exclusiveZone = 0,
    this.fixedSize = false,
    this.keyboardMode = ExpidusWindowLayerKeyboardMode.none,
    this.top = const ExpidusWindowLayerAnchor(),
    this.bottom = const ExpidusWindowLayerAnchor(),
    this.left = const ExpidusWindowLayerAnchor(),
    this.right = const ExpidusWindowLayerAnchor(),
  });

  final ExpidusWindowLayer layer;
  final String? monitor;
  final bool autoExclusiveZone;
  final int exclusiveZone;
  final bool fixedSize;
  final ExpidusWindowLayerKeyboardMode keyboardMode;
  final ExpidusWindowLayerAnchor top;
  final ExpidusWindowLayerAnchor bottom;
  final ExpidusWindowLayerAnchor left;
  final ExpidusWindowLayerAnchor right;

  dynamic toJSON() => {
        'layer': layer.name,
        'monitor': monitor,
        'autoExclusiveZone': autoExclusiveZone,
        'exclusiveZone': exclusiveZone,
        'fixedSize': fixedSize,
        'keyboardMode': keyboardMode.name,
        'top': top.toJSON(),
        'bottom': bottom.toJSON(),
        'left': left.toJSON(),
        'right': right.toJSON(),
      };

  @override
  String toString() => json.encode(toJSON());
}
