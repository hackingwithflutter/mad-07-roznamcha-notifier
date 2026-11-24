import 'package:dio/dio.dart';

import 'weather.dart';

/// The city whose weather the app shows, and where it is on the map.
const cityName = 'Lahore';
const cityLatitude = 31.558;
const cityLongitude = 74.3507;

/// Makes the Dio that talks to the weather service, Open-Meteo.
///
/// A Dio is the object that sends requests. Its options hold what every
/// request shares: the first part of the address, and how long to wait
/// before giving up.
Dio createWeatherDio() {
  return Dio(
    BaseOptions(
      baseUrl: 'https://api.open-meteo.com',
      // At most 10 seconds to reach the server,
      connectTimeout: const Duration(seconds: 10),
      // and at most 10 seconds for its response to arrive.
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}

/// Asks the weather service for the current weather in the city.
///
/// The function is `async`: it returns a Future at once, and the Future gets
/// its Weather, or an error, later, when the response has arrived.
Future<Weather> fetchCurrentWeather(Dio dio) async {
  // `await` pauses this function until the response has arrived. Dio has
  // already decoded the JSON, so `response.data!` is the map. A request can
  // fail: the `catch` block turns dio's exception into one with words the
  // app can show.
  try {
    final response = await dio.get<Map<String, dynamic>>(
      '/v1/forecast',
      queryParameters: {
        'latitude': cityLatitude,
        'longitude': cityLongitude,
        'current': 'temperature_2m',
      },
    );
    return Weather.fromJson(response.data!);
  } on DioException catch (error) {
    throw WeatherException(weatherErrorMessage(error));
  }
}

/// Says what went wrong with a request, in words for the user.
///
/// When a request fails, dio throws a DioException. Its `type` says which
/// kind of failure it was.
String weatherErrorMessage(DioException error) {
  // One sentence for each kind of failure the app can name. The enum has
  // more values than these, so the `switch` needs a `default`.
  switch (error.type) {
    case DioExceptionType.connectionError:
      return 'No internet connection.';
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
      return 'The weather service is too slow.';
    case DioExceptionType.badResponse:
      final code = error.response?.statusCode;
      return 'The weather service has a problem ($code).';
    default:
      return 'Could not load the weather.';
  }
}
