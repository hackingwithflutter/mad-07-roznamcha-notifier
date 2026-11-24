import 'package:roznamcha/data/weather.dart';

/// A weather loader for the tests: it completes at once, without the internet.
Future<Weather> fakeWeather() async {
  return const Weather(temperature: 19.9, unit: '°C');
}
