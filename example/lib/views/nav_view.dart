import 'package:expidus/expidus.dart';

class _NavViewDialog extends StatelessWidget {
  const _NavViewDialog({super.key});

  @override
  Widget build(BuildContext context) => Dialog(
  );
}

class NavViewPage extends StatelessWidget {
  const NavViewPage({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      children: [
        const Spacer(),
        Text('Navigation View', style: Theme.of(context).textTheme.displayMedium),
        Text('A page-based navigation container.', style: Theme.of(context).textTheme.labelLarge),
        Button(
          isActive: true,
          child: const Text('Run the demo'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
              ),
            );
          },
        ),
        const Spacer(),
      ],
    ),
  );
}
