import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_model.dart';

class WeatherApiClient {
  final Dio _dio;

  WeatherApiClient() : _dio = Dio(
    // Dio allows us to set a Base Configuration for all requests
    BaseOptions(
      baseUrl: 'https://api.openweathermap.org/data/2.5/',
      connectTimeout: const Duration(seconds: 5), // Fail fast if internet is dead
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  // Notice how this returns a typed WeatherModel, not a generic string!
  Future<WeatherModel?> fetchWeather(double lat, double lon) async {
    try {
      final String apiKey = dotenv.env['WEATHER_API_KEY'] ?? '';

      if (apiKey.isEmpty) {
        print("Weather API Key is missing!!!");
        return null;
      }

      // Dio's beautiful query parameter system
      final response = await _dio.get(
        'weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': apiKey,
          'units': 'metric',
        },
      );

      if (response.statusCode == 200) {
        // Dio automatically parses the JSON string into a Map<String, dynamic>.
        // We just hand that Map directly to the BuildRunner code we generated!
        return WeatherModel.fromJson(response.data);
      }

      return null;

    } on DioException catch (e) {
      // Dio gives us specific network error types (Timeout, 404, No Internet, etc.)
      print("Dio Network Error: ${e.message}");
      return null;
    } catch (e) {
      print("Unknown Parsing Error: $e");
      return null;
    }
  }
}