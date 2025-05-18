import 'package:expidus/expidus.dart';
import 'views/nav_view.dart';
import 'views/welcome.dart';

void main() {
  runApp(const ExpidusAppConfig(const ExampleApp()));
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  late FlapController _flapController;
  int _currentIndex = 0;

  static final _routes = <String, WidgetBuilder>{
    '/': (context) => const WelcomePage(),
    '/nav': (context) => const NavViewPage(),
  };

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
          onRouteChanged: (route) {
            _currentIndex =
                _routes.keys.toList().indexOf(route!.settings.name!);
          },
          flap: (nav, isDrawer) => Sidebar(
            isDrawer: isDrawer,
            currentIndex: _currentIndex,
            children: [
              SidebarItem(
                label: 'Welcome',
              ),
              SidebarItem(
                label: 'Navigation View',
              ),
            ],
            onSelected: (i) {
              setState(() {
                _currentIndex = i;
                nav.pushNamed(_routes.keys.toList()[i]);
              });
            },
          ),
          routes: _routes,
        ),
      );
}
