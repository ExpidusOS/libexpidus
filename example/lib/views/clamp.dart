import 'package:expidus/expidus.dart';

class ClampPage extends StatefulWidget {
  const ClampPage({super.key});

  @override
  State<ClampPage> createState() => _ClampPageStatus();
}

class _ClampPageStatus extends State<ClampPage> {
  double _maximumSize = 580;

  @override
  Widget build(BuildContext context) => Clamp(
        maximumSize: _maximumSize,
        child: Column(
          children: [
            PreferencesGroup(
              children: [
                ActionRow(
                  title: 'Maximum Width',
                  end: SizedBox(
                    width: 80,
                    child: TextField(
                      initialValue: '$_maximumSize',
                      keyboardType: TextInputType.number,
                      onChanged: (str) {
                        setState(() {
                          _maximumSize = double.parse(str);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
