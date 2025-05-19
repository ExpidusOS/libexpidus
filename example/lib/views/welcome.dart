import 'package:expidus/expidus.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      children: [
        const Spacer(),
        Text('Welcome to ${context.findAncestorWidgetOfExactType<Title>()!.title}', style: Theme.of(context).textTheme.displayMedium),
        Text('This is a tour of the features the library has to offer.', style: Theme.of(context).textTheme.labelLarge),
        const Spacer(),
      ],
    ),
  );
}
