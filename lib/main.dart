import 'package:material_ui/material_ui.dart';

import 'data/entry_repository.dart';
import 'data/weather.dart';
import 'data/weather_api.dart';
import 'logic/entries_notifier.dart';
import 'ui/app_flow.dart';

void main() {
  // `main` is the one place that makes the objects the whole app shares.
  // Each is made once, here, and handed down through the constructors. No
  // screen makes its own.

  // One Dio for the whole app. It knows the weather service's address and
  // how long to wait for a response.
  final dio = createWeatherDio();
  // One repository: the place where the entries are kept. To keep them
  // somewhere else, this is the only line that changes.
  final repository = InMemoryEntryRepository();
  // One notifier: every screen gets this same object, so every screen sees
  // the same entries. It lives as long as the app, so nobody disposes it.
  final notifier = EntriesNotifier(repository);
  runApp(
    RoznamchaApp(
      notifier: notifier,
      // The app gets a function that loads the weather. This one asks the
      // internet; the tests pass one that doesn't.
      loadWeather: () => fetchCurrentWeather(dio),
    ),
  );
}

/// The root widget. `MaterialApp` gives every screen below it the theme.
class RoznamchaApp extends StatelessWidget {
  const RoznamchaApp({
    super.key,
    required this.notifier,
    required this.loadWeather,
  });

  /// The object that holds the entries. It goes down to the screens through
  /// the constructors, as the weather loader does.
  final EntriesNotifier notifier;

  /// The function that loads the weather. It goes down to the home screen
  /// through the constructors: data down, as in week 4.
  final WeatherLoader loadWeather;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roznamcha',
      // The design's seed colour. Every colour in the app is made from it.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
      ),
      // AppFlow shows the welcome screen until it knows the user's name, then
      // the home screen.
      home: AppFlow(notifier: notifier, loadWeather: loadWeather),
    );
  }
}
