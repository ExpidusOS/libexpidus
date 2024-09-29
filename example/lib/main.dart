import 'package:expidus/expidus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int clicks = 0;

  @override
  Widget build(BuildContext context) => ExpidusApp(
        title: 'ExpidusOS Example Application',
        home: ExpidusScaffold(
          body: Center(
            child: Column(
              children: [
                const Spacer(),
                Text(
                    'You have pressed the button $clicks time${clicks != 1 ? 's' : ''}'),
                Button(
                  child: const Text('+1'),
                  onPressed: () {
                    setState(() {
                      clicks++;
                    });
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
}
