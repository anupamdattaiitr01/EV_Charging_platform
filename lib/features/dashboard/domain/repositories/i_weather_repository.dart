import '../entities/weather.dart';

abstract class IWeatherRepository {
  Future<Weather?> getWeather(double lat, double lon);
}