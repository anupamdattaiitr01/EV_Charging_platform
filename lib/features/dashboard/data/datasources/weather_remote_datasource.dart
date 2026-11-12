import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_model.dart';

class WeatherRemoteDataSource {
  final Dio _dio;

  WeatherRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio(
    BaseOptions(
      baseUrl: 'https://api.openweathermap.org/data/2.5/',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  Future<WeatherModel?> fetchWeather(double lat, double lon) async {
    try {
      final String apiKey = dotenv.env['WEATHER_API_KEY'] ?? '';

      if (apiKey.isEmpty) {
        return null;
      }

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
        return WeatherModel.fromJson(response.data);
      }
      return null;

    } on DioException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }
}