import 'package:material_ui/material_ui.dart';

import '../../data/weather.dart';
import '../../data/weather_api.dart';

/// The line under the greeting that shows the current temperature.
///
/// Loading the weather takes time and can fail, so the line has three
/// states, each with its own small widget, below: [WeatherLoadingRow],
/// [WeatherDataRow] and [WeatherErrorRow].
///
/// The line doesn't know where the weather comes from. It calls
/// `loadWeather`, and whoever built the line decides: the app passes a
/// function that asks the internet, and the tests pass one that doesn't.
class WeatherLine extends StatefulWidget {
  const WeatherLine({super.key, required this.loadWeather});

  /// The function that loads the weather. It returns a Future.
  final WeatherLoader loadWeather;

  @override
  State<WeatherLine> createState() => _WeatherLineState();
}

class _WeatherLineState extends State<WeatherLine> {
  // The state: the Future of the weather. `late` promises Dart that
  // initState gives the field its value before anything reads it.
  late Future<Weather> _weather;

  @override
  void initState() {
    super.initState();
    // Start loading once, when the line first appears. Not in `build`:
    // `build` runs again on every rebuild, and each run would send a new
    // request.
    _weather = widget.loadWeather();
  }

  /// Loads the weather again. The "Try again" button calls it.
  void _retry() {
    // A new Future is a new try. `setState` makes the line build again, and
    // the FutureBuilder follows the new Future.
    setState(() {
      _weather = widget.loadWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      // A FutureBuilder listens to a Future. It calls `builder` now, and
      // again when the Future completes. `snapshot` says how far the Future
      // is at that moment.
      child: FutureBuilder<Weather>(
        future: _weather,
        builder: (context, snapshot) {
          // One row for each state of the Future. `waiting` is checked
          // first: after "Try again", the snapshot still holds the old error
          // while the new Future is waiting.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const WeatherLoadingRow();
          }
          if (snapshot.hasError) {
            return WeatherErrorRow(error: snapshot.error, onRetry: _retry);
          }
          return WeatherDataRow(weather: snapshot.data!);
        },
      ),
    );
  }
}

/// State 1: the response has not arrived yet.
class WeatherLoadingRow extends StatelessWidget {
  const WeatherLoadingRow({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          // A turning circle: the app is waiting, and it is not frozen.
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 8),
        // Expanded gives the text the width that is left, so a long text is
        // cut with "…" and can't overflow the Row (week 3).
        Expanded(
          child: Text(
            'Loading the weather...',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

/// State 2: the weather has arrived.
class WeatherDataRow extends StatelessWidget {
  const WeatherDataRow({super.key, required this.weather});

  /// The weather this row shows.
  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(Icons.thermostat, size: 20, color: colors.onSurfaceVariant),
        const SizedBox(width: 8),
        // `round` gives the nearest whole number: 19.9 becomes 20.
        Text(
          '${weather.temperature.round()}${weather.unit} in $cityName',
          style: text.bodyLarge,
        ),
        const SizedBox(width: 12),
        // The weather service asks every app that shows its data to name it.
        Expanded(
          child: Text(
            'Weather data by Open-Meteo.com',
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.labelSmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

/// State 3: loading failed. It says why, and offers "Try again".
///
/// Like week 4's buttons, the row doesn't know what trying again does. It
/// calls `onRetry`, and whoever built the row decides.
class WeatherErrorRow extends StatelessWidget {
  const WeatherErrorRow({
    super.key,
    required this.error,
    required this.onRetry,
  });

  /// What the Future failed with.
  final Object? error;

  /// Called when the user taps "Try again".
  final VoidCallback onRetry;

  /// The sentence the row shows.
  String get _message {
    // Copy the field into a local variable, so `is` can promote it (week 2),
    // and `.message` compiles.
    final error = this.error;
    if (error is WeatherException) {
      return error.message;
    }
    return 'Could not load the weather.';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(Icons.cloud_off, size: 20, color: colors.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    );
  }
}
