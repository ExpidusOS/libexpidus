import 'package:expidus/expidus.dart';

class _NavViewDialog extends StatelessWidget {
  const _NavViewDialog({
    super.key,
    this.onClose,
  });

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) => Dialog(
    routes: {
      '/': (context) => DialogPage(
        title: 'Page 1',
        onClose: onClose,
        child: Center(
          child: Column(
            spacing: 3.0,
            children: [
              const Spacer(),
              Button(
                isActive: true,
                child: const Text('Open Page 2'),
                onPressed: () {
                  Navigator.pushNamed(context, '/2');
                },
              ),
              Button(
                isActive: true,
                child: const Text('Open Page 3'),
                onPressed: () {
                  Navigator.pushNamed(context, '/3');
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
      '/2': (context) => DialogPage(
        title: 'Page 2',
        onClose: onClose,
        child: Center(
          child: Column(
            spacing: 3.0,
            children: [
              const Spacer(),
              Button(
                isActive: true,
                child: const Text('Open Page 4'),
                onPressed: () {
                  Navigator.pushNamed(context, '/4');
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
      '/3': (_) => DialogPage(
        title: 'Page 3',
        onClose: onClose,
        child: const Center(
          child: Text('Page 3'),
        ),
      ),
      '/4': (context) => DialogPage(
        title: 'Page 4',
        onClose: onClose,
        child: Center(
          child: Column(
            spacing: 3.0,
            children: [
              const Spacer(),
              Button(
                isActive: true,
                child: const Text('Open Page 3'),
                onPressed: () {
                  Navigator.pushNamed(context, '/3');
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    },
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
          child: const Text('Run the demo'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => _NavViewDialog(
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
