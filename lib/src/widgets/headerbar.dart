import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';
import '../logic/method_channel.dart';
import 'app.dart';

class HeaderBar extends StatefulWidget {
  const HeaderBar({
    super.key,
    this.title,
    this.titleWidget,
    this.onGenerateTitle,
    this.start = const [],
    this.end = const [],
    this.hasDrawer = false,
    this.onDrawerToggle,
    this.showActions,
  });

  final String? title;
  final Widget? titleWidget;
  final GenerateAppTitle? onGenerateTitle;
  final List<Widget> start;
  final List<Widget> end;
  final bool hasDrawer;
  final VoidCallback? onDrawerToggle;
  final bool? showActions;

  @override
  State<HeaderBar> createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar> {
  late ValueNotifier<List<String>?> separator = _showActions(context)
      ? ValueNotifier(
          ['menu', 'minimize,maximize,close'],
        )
      : ValueNotifier(['menu', '']);

  bool _showActions(BuildContext context) =>
      widget.showActions ??
      (defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.macOS ||
              defaultTargetPlatform == TargetPlatform.windows) &&
          !ExpidusApp.hasWindowLayer(context);

  @override
  void initState() {
    super.initState();

    if (_showActions(context)) {
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
        ExpidusMethodChannel.instance.getHeaderBarLayout().then((order) {
          updateSep(order);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: ExpidusApp.of(context).hasWindowLayer,
        builder: (context, _hasWindowLayer, _) {
          final ScaffoldState? scaffold = Scaffold.maybeOf(context);
          final bool hasDrawer = scaffold?.hasDrawer ?? widget.hasDrawer;

          final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
          final bool useCloseButton =
              parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog;

          final windowButtons = <String, Widget?>{
            'menu': hasDrawer
                ? DrawerButton(onPressed: widget.onDrawerToggle)
                : (parentRoute?.impliesAppBarDismissal ??
                        false && !useCloseButton
                    ? const BackButton()
                    : null),
            'maximize': _showActions(context)
                ? AdwWindowButton(
                    nativeControls: true,
                    buttonType: WindowButtonType.maximize,
                    onPressed: () => appWindow!.maximize(),
                  )
                : null,
            'minimize': _showActions(context)
                ? AdwWindowButton(
                    nativeControls: true,
                    buttonType: WindowButtonType.minimize,
                    onPressed: () => appWindow!.minimize(),
                  )
                : null,
            'close': _showActions(context)
                ? AdwWindowButton(
                    nativeControls: true,
                    buttonType: WindowButtonType.close,
                    onPressed: () => appWindow!.close(),
                  )
                : null,
          };

          final widgetsApp =
              context.findAncestorWidgetOfExactType<WidgetsApp>()!;

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
                                if (sep != null &&
                                    sep[0].split(',').isNotEmpty) ...[
                                  SizedBox(width: 6),
                                  for (var i in sep[0].split(','))
                                    if (windowButtons[i] != null)
                                      windowButtons[i]!,
                                  if (defaultTargetPlatform ==
                                      TargetPlatform.linux)
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
                                if (sep != null &&
                                    sep[1].split(',').isNotEmpty) ...[
                                  SizedBox(width: 6),
                                  for (var i in sep[1].split(','))
                                    if (windowButtons[i] != null)
                                      windowButtons[i]!,
                                  if (defaultTargetPlatform ==
                                      TargetPlatform.linux)
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
        },
      );
}
