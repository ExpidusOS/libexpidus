import 'package:flutter/material.dart';
import 'button.dart';

const String _bothLabelAndLabelWidget = """
Either use label or use labelWidget, both can't be assigned at once.""";

/// View that is normally used to place navigation and selection items
/// at the side of the app.
///
/// You can use the [Sidebar.builder] constructor to build the sidebar's
/// children on demand.
class Sidebar extends StatelessWidget {
  Sidebar({
    super.key,
    required this.currentIndex,
    required this.onSelected,
    this.borderRadius,
    this.width = 280.0,
    this.color,
    this.isDrawer = false,
    this.controller,
    this.padding = const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
    required List<SidebarItem> children,
  }) : _childrenDelegate = List.generate(
          children.length,
          (index) => _SidebarItemBuilder(
            item: (context) => children[index],
            isDrawer: isDrawer,
            isSelected: index == currentIndex,
            onSelected: () => onSelected(index),
          ),
        );

  Sidebar.builder({
    super.key,
    required this.currentIndex,
    required this.onSelected,
    this.borderRadius,
    this.width = 280.0,
    this.color,
    this.isDrawer = false,
    this.controller,
    this.padding = const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
    required SidebarItem Function(
      BuildContext context,
      int index,
      bool isSelected,
    ) itemBuilder,
    required int itemCount,
  })  : assert(itemCount >= 0, 'Item Count cannot not be negative!'),
        _childrenDelegate = List.generate(
          itemCount,
          (index) => _SidebarItemBuilder(
            item: (context) =>
                itemBuilder(context, index, currentIndex == index),
            isSelected: currentIndex == index,
            isDrawer: isDrawer,
            onSelected: () => onSelected(index),
          ),
        );

  /// The current index of the item selected.
  final int? currentIndex;

  /// The padding of the sidebar.
  ///
  /// Defaults to `EdgeInsets.symmetric(vertical: 5, horizontal: 6)`.
  final EdgeInsets? padding;

  final BorderRadiusGeometry? borderRadius;

  /// Scroll controller for sidebar.
  final ScrollController? controller;

  /// Called when one of the Sidebar item is selected.
  final void Function(int index) onSelected;

  /// Is the Sidebar present in the Drawer of the Scaffold
  final bool isDrawer;

  /// The width of the sidebar.
  ///
  /// Defaults to `280.0`.
  final double width;

  /// The background color of the sidebar.
  final Color? color;

  /// Delegate in charge of supplying children to the internal list
  /// of this widget.
  final List<Widget> _childrenDelegate;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: width),
      decoration: ShapeDecoration(
        color: color ?? Theme.of(context).colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
      child: ListView(
        controller: controller,
        padding: padding,
        children: _childrenDelegate,
      ),
    );
  }
}

/// Class that contains details about a specific sidebar item.
class SidebarItem {
  const SidebarItem({
    this.key,
    this.label,
    this.padding = const EdgeInsets.symmetric(horizontal: 14),
    this.selectedColor,
    this.unselectedColor,
    this.labelStyle,
    this.labelWidget,
    this.leading,
  }) : assert(
          labelWidget != null || label != null,
          _bothLabelAndLabelWidget,
        );

  /// The key of the sidebar item child.
  final Key? key;

  /// The label to render to the right of the button.
  final String? label;

  /// The background color of the item when it is selected.
  ///
  /// Defaults to Theme's primary color
  final Color? selectedColor;

  /// The background color of the item when it is not selected.
  ///
  /// Defaults to `null`.
  final Color? unselectedColor;

  /// The style of the label
  final TextStyle? labelStyle;

  /// The label to render to the right of the button
  final Widget? labelWidget;

  /// Widget that would be placed at the left of the [labelWidget].
  final Widget? leading;

  /// The Padding of the item.
  final EdgeInsets padding;
}

class _SidebarItemBuilder extends StatelessWidget {
  const _SidebarItemBuilder({
    required this.item,
    required this.isSelected,
    required this.isDrawer,
    this.onSelected,
  });

  final SidebarItem Function(BuildContext context) item;
  final bool isSelected;
  final VoidCallback? onSelected;
  final bool isDrawer;

  @override
  Widget build(BuildContext context) {
    final currentItem = item(context);

    return Button.pill(
      constraints: const BoxConstraints.tightFor(height: 36),
      margin: const EdgeInsets.only(bottom: 2),
      textStyle: Theme.of(context).textTheme.displayMedium ??
          const TextStyle(fontWeight: FontWeight.normal),
      padding: currentItem.padding,
      onPressed: () {
        onSelected?.call();
        if (isDrawer) {
          Navigator.of(context).pop();
        }
      },
      isActive: isSelected,
      child: Row(
        children: [
          if (currentItem.leading != null) ...[
            currentItem.leading!,
            const SizedBox(width: 12),
          ],
          currentItem.labelWidget ??
              Text(
                currentItem.label!,
                style: (currentItem.labelStyle ??
                        Theme.of(context).textTheme.labelLarge ??
                        const TextStyle(
                          fontSize: 15,
                        ))
                    .copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
        ],
      ),
    );
  }
}
