import 'package:expidus/expidus.dart';

class ListsPage extends StatefulWidget {
  const ListsPage({super.key});

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  int? _radio = 0;

  @override
  Widget build(BuildContext context) => Clamp(
        maximumSize: 400,
        child: Column(
          children: [
            const PreferencesGroup(
              children: [
                ActionRow(
                  title: 'Rows have a title',
                  subtitle: 'They also have a subtitle',
                ),
                ActionRow(
                  title: 'Rows can have suffix widgets',
                  end: Button(
                    isActive: true,
                    child: Text('Action'),
                  ),
                ),
              ],
            ),
            PreferencesGroup(
              children: [
                ActionRow(
                  title: 'Row can have prefix widgets',
                  start: Radio<int>(
                    value: 0,
                    groupValue: _radio,
                    onChanged: (value) {
                      setState(() {
                        _radio = value;
                      });
                    },
                  ),
                ),
                ActionRow(
                  title: 'Row can have prefix widgets',
                  start: Radio<int>(
                    value: 1,
                    groupValue: _radio,
                    onChanged: (value) {
                      setState(() {
                        _radio = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
