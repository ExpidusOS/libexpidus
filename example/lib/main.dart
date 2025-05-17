import 'package:expidus/expidus.dart';

void main() {
  runApp(const ExpidusAppConfig(const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FlapController _flapController;
  int clicks = 0;

  @override
  void initState() {
    super.initState();

    _flapController = FlapController();
    _flapController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) => ExpidusApp(
        title: 'ExpidusOS Example Application',
        home: ExpidusScaffold(
          flapController: _flapController,
          flap: (isDrawer) => Sidebar(
            isDrawer: isDrawer,
            currentIndex: 0,
            children: [
              SidebarItem(
                label: 'Home',
              ),
            ],
            onSelected: (i) => {},
          ),
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
