import '../../domain/entities/weather.dart';
import '../../domain/repositories/i_weather_repository.dart';
import '../datasources/weather_remote_datasource.dart';

class WeatherRepositoryImpl implements IWeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  WeatherRepositoryImpl(this.remoteDataSource);

  @override
  Future<Weather?> getWeather(double lat, double lon) async {
    try {
      final weatherModel = await remoteDataSource.fetchWeather(lat, lon);

      if (weatherModel != null) {
        // Map the data model to the domain entity
        return Weather(
          temperature: "${weatherModel.roundedTemp}°C",
          condition: weatherModel.condition,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}