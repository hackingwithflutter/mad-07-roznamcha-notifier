import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roznamcha/data/weather.dart';
import 'package:roznamcha/data/weather_api.dart';

import 'weather_test.dart' show lahoreResponse;

/// Stands in for the internet in these tests. Dio hands every request to
/// its adapter. This one responds from memory, so no test needs a network.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.respond);

  /// Makes the response to a request, or throws what a failed request
  /// throws.
  final ResponseBody Function(RequestOptions options) respond;

  /// The requests this adapter got, in order.
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

/// A response whose body is the JSON [text], with a status code.
ResponseBody jsonResponse(String text, {int statusCode = 200}) {
  return ResponseBody.fromString(
    text,
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

/// The app's own Dio, with [adapter] in place of the internet.
Dio dioWith(FakeAdapter adapter) {
  return createWeatherDio()..httpClientAdapter = adapter;
}

/// A DioException of the given [type], as dio would throw it.
DioException failure(DioExceptionType type, {int? statusCode}) {
  final options = RequestOptions(path: '/v1/forecast');
  return DioException(
    requestOptions: options,
    type: type,
    response: statusCode == null
        ? null
        : Response<dynamic>(requestOptions: options, statusCode: statusCode),
  );
}

void main() {
  // Week 6's tests. All ten pass: the request is given code now.
  test('The Dio knows the address and waits at most 10 seconds', () {
    final dio = createWeatherDio();
    expect(dio.options.baseUrl, 'https://api.open-meteo.com');
    expect(dio.options.connectTimeout, const Duration(seconds: 10));
    expect(dio.options.receiveTimeout, const Duration(seconds: 10));
  });

  test('Android lets the app use the internet in every build', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml');
    expect(
      manifest.readAsStringSync(),
      contains('android.permission.INTERNET'),
    );
  });

  // Week 6, TODO 5
  test(
    'The request is a GET for the current temperature in the city',
    () async {
      final adapter = FakeAdapter((options) => jsonResponse(lahoreResponse));
      await fetchCurrentWeather(dioWith(adapter));
      expect(adapter.requests.length, 1);
      final request = adapter.requests.first;
      expect(request.method, 'GET');
      expect(request.uri.host, 'api.open-meteo.com');
      expect(request.uri.path, '/v1/forecast');
      expect(request.uri.queryParameters, {
        'latitude': '$cityLatitude',
        'longitude': '$cityLongitude',
        'current': 'temperature_2m',
      });
    },
  );

  // Week 6, TODO 5 and TODO 1
  test('The response becomes a Weather', () async {
    final adapter = FakeAdapter((options) => jsonResponse(lahoreResponse));
    final weather = await fetchCurrentWeather(dioWith(adapter));
    expect(weather.temperature, 19.9);
    expect(weather.unit, '°C');
  });

  // Week 6, TODO 6
  test('A connection error says there is no internet', () {
    final error = failure(DioExceptionType.connectionError);
    expect(weatherErrorMessage(error), 'No internet connection.');
  });

  test('Both timeouts say the service is too slow', () {
    const slow = 'The weather service is too slow.';
    final connect = failure(DioExceptionType.connectionTimeout);
    final receive = failure(DioExceptionType.receiveTimeout);
    expect(weatherErrorMessage(connect), slow);
    expect(weatherErrorMessage(receive), slow);
  });

  test('A bad response says so, with its status code', () {
    final error = failure(DioExceptionType.badResponse, statusCode: 500);
    expect(
      weatherErrorMessage(error),
      'The weather service has a problem (500).',
    );
  });

  test('Any other failure gets the general sentence', () {
    final error = failure(DioExceptionType.unknown);
    expect(weatherErrorMessage(error), 'Could not load the weather.');
  });

  // Week 6, TODO 7
  test('Without internet, the Future fails with a WeatherException', () async {
    final adapter = FakeAdapter((options) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'No network in this test.',
      );
    });
    Object? caught;
    try {
      await fetchCurrentWeather(dioWith(adapter));
    } catch (error) {
      caught = error;
    }
    expect(caught, isA<WeatherException>());
    expect((caught as WeatherException).message, 'No internet connection.');
  });

  test(
    'A 500 response fails with a WeatherException that has the code',
    () async {
      final adapter = FakeAdapter(
        (options) => jsonResponse('{"error": true}', statusCode: 500),
      );
      Object? caught;
      try {
        await fetchCurrentWeather(dioWith(adapter));
      } catch (error) {
        caught = error;
      }
      expect(caught, isA<WeatherException>());
      expect(
        (caught as WeatherException).message,
        'The weather service has a problem (500).',
      );
    },
  );
}
