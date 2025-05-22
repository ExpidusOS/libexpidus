import 'package:expidus/expidus.dart';

class _ViewSwitcherDialog extends StatefulWidget {
  const _ViewSwitcherDialog({
    super.key,
    this.onClose,
  });

  final VoidCallback? onClose;

  @override
  State<_ViewSwitcherDialog> createState() => _ViewSwitcherDialogState();
}

class _ViewSwitcherDialogState extends State<_ViewSwitcherDialog> {
  ValueNotifier<int> _index = ValueNotifier(0);

  @override
  Widget build(BuildContext context) => Dialog(
        home: ValueListenableBuilder(
          valueListenable: _index,
          builder: (context, index, _) => DialogPage(
            onClose: widget.onClose,
            titleWidget: ViewSwitcher(
              tabs: const [
                ViewSwitcherData(
                  title: 'World',
                  icon: Icons.public,
                ),
                ViewSwitcherData(
                  title: 'Alarm',
                  icon: Icons.alarm,
                ),
                ViewSwitcherData(
                  title: 'Stopwatch',
                  icon: Icons.stop,
                  badge: '9',
                ),
                ViewSwitcherData(
                  title: 'Timer',
                  icon: Icons.timer,
                  badge: '1',
                ),
              ],
              onViewChanged: (i) => _index.value = i,
              currentIndex: index,
            ),
            child: ViewStack(
              index: index,
              children: [
                Center(
                  child: Text('World'),
                ),
                Center(
                  child: Text('Alarm'),
                ),
                Center(
                  child: Text('Stopwatch'),
                ),
                Center(
                  child: Text('Timer'),
                ),
              ],
            ),
          ),
        ),
      );
}

class ViewSwitcherPage extends StatelessWidget {
  const ViewSwitcherPage({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          children: [
            const Spacer(),
            Text('View Switcher',
                style: Theme.of(context).textTheme.displayMedium),
            Text('Widgets to switch the window\'s view.',
                style: Theme.of(context).textTheme.labelLarge),
            Button(
              child: const Text('Run the demo'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => _ViewSwitcherDialog(
                    onClose: () {
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
            const Spacer(),
          ],
        ),
      );
}
