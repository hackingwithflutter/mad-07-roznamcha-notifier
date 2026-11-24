import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:roznamcha/data/weather.dart';

/// A real response of the weather service for Lahore, copied on 22 Nov 2026
/// and laid out on several lines. `'''` starts and ends a text of several
/// lines.
const lahoreResponse = '''
{
  "latitude": 31.599297,
  "longitude": 74.371254,
  "generationtime_ms": 0.03170967102050781,
  "utc_offset_seconds": 0,
  "timezone": "GMT",
  "timezone_abbreviation": "GMT",
  "elevation": 219.0,
  "current_units": {
    "time": "iso8601",
    "interval": "seconds",
    "temperature_2m": "°C"
  },
  "current": {
    "time": "2026-11-22T12:30",
    "interval": 900,
    "temperature_2m": 19.9
  }
}
''';

/// Turns JSON text into nested maps, as dio does with a response.
Map<String, dynamic> decode(String text) {
  return jsonDecode(text) as Map<String, dynamic>;
}

void main() {
  // Week 6's tests. All four pass: the model class is given code now.
  // Week 6, TODO 1
  test('fromJson reads the temperature and the unit of a real response', () {
    final weather = Weather.fromJson(decode(lahoreResponse));
    expect(weather.temperature, 19.9);
    expect(weather.unit, '°C');
  });

  test('fromJson accepts a temperature written without a decimal point', () {
    // In JSON, 20 and 20.0 are the same number. In Dart, 20 is an int.
    final weather = Weather.fromJson(
      decode('''
{
  "current_units": {"temperature_2m": "°C"},
  "current": {"temperature_2m": 20}
}
'''),
    );
    expect(weather.temperature, 20.0);
  });

  test('fromJson reads a temperature below zero, and another unit', () {
    final weather = Weather.fromJson(
      decode('''
{
  "current_units": {"temperature_2m": "°F"},
  "current": {"temperature_2m": -3.5}
}
'''),
    );
    expect(weather.temperature, -3.5);
    expect(weather.unit, '°F');
  });

  test('fromJson throws when the response has no weather in it', () {
    // What the service sends for a wrong request, with the status code 400.
    const errorBody = '{"error": true, "reason": "Not Found"}';
    expect(() => Weather.fromJson(decode(errorBody)), throwsA(anything));
  });
}
