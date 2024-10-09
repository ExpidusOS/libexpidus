import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../logic/method_channel.dart';

class InputShapeRegion extends StatelessWidget {
  const InputShapeRegion({
    super.key,
    this.enable = true,
    required this.child,
  });

  final bool enable;
  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder props) {
    super.debugFillProperties(props);

    props.add(FlagProperty(
      'region is',
      value: enable,
      ifTrue: 'active',
      ifFalse: 'inactive',
    ));

    props.add(DiagnosticsProperty<Widget>('child', child));
  }

  @override
  bool operator ==(Object other) {
    if (other is InputShapeRegion) {
      return super == other && other.enable == enable && other.child == child;
    }
    return super == other;
  }

  @override
  Widget build(BuildContext context) => child;
}

class _InputShapeTreeNavigator {
  factory _InputShapeTreeNavigator(BuildContext context) {
    var items = <StatelessElement>[];

    context.visitChildElements((el) {
      if (el is StatelessElement) {
        if (el.widget is InputShapeRegion) {
          items.add(el);
          return;
        }
      }

      items.addAll(_InputShapeTreeNavigator(el).elements);
    });

    return _InputShapeTreeNavigator._(items);
  }

  const _InputShapeTreeNavigator._(this.elements);

  final List<StatelessElement> elements;
}

class InputShapeCombineRegions extends StatefulWidget {
  const InputShapeCombineRegions({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<InputShapeCombineRegions> createState() =>
      InputShapeCombineRegionsState();
}

class InputShapeCombineRegionsState extends State<InputShapeCombineRegions> {
  List<StatelessElement> _regions = [];
  List<InputShapeRegion> get regions => List.unmodifiable(_regions
      .where((region) => (region.widget as InputShapeRegion).enable)
      .map((el) => el.widget as InputShapeRegion));

  List<Rect> get rects => _regions
          .where((region) => (region.widget as InputShapeRegion).enable)
          .map((region) {
        final renderBox = region.renderObject as RenderBox;
        return renderBox.localToGlobal(Offset.zero) & renderBox.size;
      }).toList();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder props) {
    super.debugFillProperties(props);

    props.add(IterableProperty<InputShapeRegion>(
      'regions',
      regions,
      style: DiagnosticsTreeStyle.truncateChildren,
    ));

    props.add(IterableProperty<Rect>(
      'rects',
      rects,
      style: DiagnosticsTreeStyle.truncateChildren,
    ));
  }

  void updateRegions() {
    _regions.clear();
    _regions.addAll(_InputShapeTreeNavigator(context).elements);

    ExpidusMethodChannel.instance.setInputShapeRegions(rects);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      updateRegions();
    });
  }

  @override
  void didUpdateWidget(covariant InputShapeCombineRegions oldWidget) {
    super.didUpdateWidget(oldWidget);

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      updateRegions();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
