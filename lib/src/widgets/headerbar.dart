import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libadwaita/libadwaita.dart';

class HeaderBar extends StatefulWidget {
  const HeaderBar({
    super.key,
    this.title,
    this.titleWidget,
    this.onGenerateTitle,
    this.start = const [],
    this.end = const [],
    this.menuItems = const [],
    this.showActions,
  });

  final String? title;
  final Widget? titleWidget;
  final GenerateAppTitle? onGenerateTitle;
  final List<Widget> start;
  final List<Widget> end;
  final List<PopupMenuEntry> menuItems;
  final bool? showActions;

  @override
  State<HeaderBar> createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar> {
  static final _methodChannel = MethodChannel('expidus');

  bool get _showActions =>
      widget.showActions ??
      (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows);

  late ValueNotifier<List<String>?> separator = _showActions
      ? ValueNotifier(
          ['menu', 'minimize,maximize,close'],
        )
      : ValueNotifier(null);

  @override
  void initState() {
    super.initState();

    if (_showActions) {
      void updateSep(String order) {
        if (!mounted) return;
        separator.value = order.split(':')
          ..map<String>(
            (e) => e
                .split(',')
                .where(
                  (element) =>
                      element == 'close' ||
                      element == 'maximize' ||
                      element == 'minimize',
                )
                .join(','),
          );
      }

      if (defaultTargetPlatform == TargetPlatform.macOS) {
        updateSep('close,minimize,maximize:menu');
      } else {
        _methodChannel.invokeMethod('getHeaderBarLayout').then((order) {
          updateSep(order);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final windowButtons = <String, Widget?>{
      'menu': widget.menuItems.length > 0
          ? PopupMenuButton(
              itemBuilder: (_) => widget.menuItems,
            )
          : null,
      'maximize': AdwWindowButton(
        nativeControls: true,
        buttonType: WindowButtonType.maximize,
        onPressed: () => appWindow!.maximize(),
      ),
      'minimize': AdwWindowButton(
        nativeControls: true,
        buttonType: WindowButtonType.minimize,
        onPressed: () => appWindow!.minimize(),
      ),
      'close': AdwWindowButton(
        nativeControls: true,
        buttonType: WindowButtonType.close,
        onPressed: () => appWindow!.close(),
      ),
    };

    final widgetsApp = context.findAncestorWidgetOfExactType<WidgetsApp>()!;

    final onGenerateTitle =
        widget.onGenerateTitle ?? widgetsApp.onGenerateTitle;
    final title = widget.title ?? widgetsApp.title ?? '';

    return Material(
      type: MaterialType.transparency,
      elevation: Theme.of(context).appBarTheme.elevation ?? 3.0,
      shadowColor: Theme.of(context).appBarTheme.shadowColor,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (_) => appWindow!.startDragging(),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            decoration: ShapeDecoration(
              color: Theme.of(context).appBarTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            height: 50,
            width: double.infinity,
            child: Stack(
              children: [
                ValueListenableBuilder<List<String>?>(
                  valueListenable: separator,
                  builder: (context, sep, _) => DefaultTextStyle.merge(
                    style: Theme.of(context).textTheme.titleLarge ??
                        const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                    child: NavigationToolbar(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_showActions &&
                              sep != null &&
                              sep[0].split(',').isNotEmpty) ...[
                            SizedBox(width: 6),
                            for (var i in sep[0].split(','))
                              if (windowButtons[i] != null) windowButtons[i]!,
                            if (defaultTargetPlatform == TargetPlatform.linux)
                              SizedBox(width: 6),
                          ],
                          ...widget.start.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: e,
                            ),
                          ),
                        ],
                      ),
                      middle: widget.titleWidget ??
                          Text(
                            (onGenerateTitle != null
                                    ? onGenerateTitle!(context)
                                    : null) ??
                                title,
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                          ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...widget.end.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: e,
                            ),
                          ),
                          if (_showActions &&
                              sep != null &&
                              sep[1].split(',').isNotEmpty) ...[
                            SizedBox(width: 6),
                            for (var i in sep[1].split(','))
                              if (windowButtons[i] != null) windowButtons[i]!,
                            if (defaultTargetPlatform == TargetPlatform.linux)
                              SizedBox(width: 6),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
