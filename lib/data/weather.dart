/// The current weather, as the app needs it: the temperature and its unit.
///
/// The weather service's response is JSON, and JSON becomes nested maps in
/// Dart. This class turns those maps into an object with real types, so the
/// rest of the app writes `weather.temperature` and never `json['current']`.
class Weather {
  const Weather({required this.temperature, required this.unit});

  /// Makes a Weather from the weather service's response.
  ///
  /// A `factory` constructor runs code first, and then returns an object.
  /// [json] is the whole response, already decoded: a map whose values can be
  /// anything, so their type is `dynamic`. The part the app needs looks like
  /// this:
  ///
  /// ```json
  /// {
  ///   "current_units": {"temperature_2m": "°C"},
  ///   "current": {"temperature_2m": 19.9}
  /// }
  /// ```
  factory Weather.fromJson(Map<String, dynamic> json) {
    // Two maps inside the map, each told to Dart with a cast. The
    // temperature is cast to `num` first, and then turned into a double: a
    // JSON number can be 20 or 19.9.
    final current = json['current'] as Map<String, dynamic>;
    final units = json['current_units'] as Map<String, dynamic>;
    return Weather(
      temperature: (current['temperature_2m'] as num).toDouble(),
      unit: units['temperature_2m'] as String,
    );
  }

  /// The air temperature, such as 19.9.
  final double temperature;

  /// The unit of [temperature], such as `°C`.
  final String unit;
}

/// An error with a message that the app can show to the user.
///
/// `implements Exception` says that objects of this class are made to be
/// thrown with `throw` and caught with `catch`.
class WeatherException implements Exception {
  const WeatherException(this.message);

  /// What went wrong, in words for the user.
  final String message;

  @override
  String toString() => 'WeatherException: $message';
}

/// The type of a function that loads the weather: it takes nothing and
/// returns a Future of a Weather. It is a name for a function type, as
/// `VoidCallback` is a name for `void Function()` (week 4).
typedef WeatherLoader = Future<Weather> Function();
