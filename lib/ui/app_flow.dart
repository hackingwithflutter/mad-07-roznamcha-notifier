import 'package:material_ui/material_ui.dart';

import '../data/weather.dart';
import '../logic/entries_notifier.dart';
import 'screens/home_screen.dart';
import 'screens/name_form_screen.dart';
import 'screens/welcome_screen.dart';

/// The flow from the welcome screen to the home screen.
///
/// In step 2 this widget remembered two things: whether the user tapped
/// "Get started", and their name. Step 3 hands the first one to the
/// Navigator: the name form is now a screen pushed on top of the welcome
/// screen, so the phone's back button closes it. This widget still remembers
/// the name, and its `build` still returns the screen that fits it.
///
/// Step 4 added one thing: the function that loads the weather passes
/// through here, on its way to the home screen. Step 5 adds a second
/// passenger, the notifier that holds the entries. This widget uses neither.
/// It only hands them on.
class AppFlow extends StatefulWidget {
  const AppFlow({super.key, required this.notifier, required this.loadWeather});

  /// The object that holds the entries, for the home screen.
  final EntriesNotifier notifier;

  /// The function that loads the weather, for the home screen.
  final WeatherLoader loadWeather;

  @override
  State<AppFlow> createState() => _AppFlowState();
}

class _AppFlowState extends State<AppFlow> {
  // The state: the user's name, or null while the app doesn't know it.
  String? _name;

  /// Opens the name form on top of the welcome screen.
  void _openNameForm() {
    // Navigator.push puts a new route (a screen) on top of the stack.
    // MaterialPageRoute builds the screen and slides it in. `<void>` says
    // the screen gives nothing back when it closes.
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => NameFormScreen(onSubmit: _saveName),
      ),
    );
  }

  /// Runs when the name form reports a valid name.
  void _saveName(String value) {
    // Navigator.pop takes the top route, the name form, off the stack.
    Navigator.pop(context);
    // setState makes build run again, so the screen under the form is now
    // the home screen.
    setState(() {
      _name = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Copy the field into a local variable, so Dart can promote it from
    // `String?` to `String` inside the `if` (week 2: promotion works for
    // local variables, not for fields).
    final name = _name;
    if (name != null) {
      return HomeScreen(
        name: name,
        notifier: widget.notifier,
        loadWeather: widget.loadWeather,
      );
    }
    return WelcomeScreen(onGetStarted: _openNameForm);
  }
}
