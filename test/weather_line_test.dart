import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:roznamcha/data/weather.dart';
import 'package:roznamcha/data/weather_api.dart';
import 'package:roznamcha/ui/widgets/weather_line.dart';

import 'fake_weather.dart';
import 'phone.dart';

/// Builds the weather line alone, on the phone-sized screen. It loads the
/// weather with [loadWeather].
Future<void> pumpLine(WidgetTester tester, WeatherLoader loadWeather) async {
  await pumpOnPhone(
    tester,
    MaterialApp(
      home: Scaffold(body: WeatherLine(loadWeather: loadWeather)),
    ),
  );
}

void main() {
  // Week 6's tests. All seven pass: the weather line is given code now.
  testWidgets('The weather is loaded once, however often the line is built', (
    tester,
  ) async {
    var loads = 0;
    Future<Weather> countingWeather() {
      loads++;
      return fakeWeather();
    }

    await pumpLine(tester, countingWeather);
    await tester.pump();
    // Building the same line again must not start a second load.
    await pumpLine(tester, countingWeather);
    await tester.pump();
    expect(loads, 1);
  });

  // Week 6, TODO 3
  testWidgets('While the weather is loading, the line says so', (tester) async {
    // A Completer makes a Future that this test completes when it wants.
    // Here it never does, so the line stays in its first state.
    final weather = Completer<Weather>();
    await pumpLine(tester, () => weather.future);
    await tester.pump();
    expect(find.text('Loading the weather...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('When the weather arrives, the line shows it', (tester) async {
    final weather = Completer<Weather>();
    await pumpLine(tester, () => weather.future);
    weather.complete(const Weather(temperature: 19.9, unit: '°C'));
    await tester.pump();
    // 19.9 is shown as the nearest whole number.
    expect(find.text('20°C in $cityName'), findsOneWidget);
    expect(find.textContaining('Open-Meteo.com'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('When loading fails, the line shows why, and Try again', (
    tester,
  ) async {
    await pumpLine(tester, () async {
      throw const WeatherException('No internet connection.');
    });
    await tester.pump();
    expect(find.text('No internet connection.'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Try again'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('An error of another kind gets the general sentence', (
    tester,
  ) async {
    await pumpLine(tester, () async {
      throw const FormatException('Not what the app expected.');
    });
    await tester.pump();
    expect(find.text('Could not load the weather.'), findsOneWidget);
  });

  // Week 6, TODO 4
  testWidgets('Try again loads the weather again, and shows it', (
    tester,
  ) async {
    var loads = 0;
    Future<Weather> failsOnce() async {
      loads++;
      if (loads == 1) {
        throw const WeatherException('No internet connection.');
      }
      return const Weather(temperature: 19.9, unit: '°C');
    }

    await pumpLine(tester, failsOnce);
    await tester.pump();
    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump();
    expect(loads, 2);
    expect(find.text('20°C in $cityName'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('After Try again, the line shows loading, not the old error', (
    tester,
  ) async {
    final second = Completer<Weather>();
    var loads = 0;
    Future<Weather> failsThenWaits() {
      loads++;
      if (loads == 1) {
        return Future.error(const WeatherException('No internet connection.'));
      }
      return second.future;
    }

    await pumpLine(tester, failsThenWaits);
    await tester.pump();
    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(find.text('Loading the weather...'), findsOneWidget);
    expect(find.text('No internet connection.'), findsNothing);
  });
}
