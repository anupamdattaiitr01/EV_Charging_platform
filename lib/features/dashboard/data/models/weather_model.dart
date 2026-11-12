import 'package:json_annotation/json_annotation.dart';

// WARNING: This line will show a RED ERROR right now.
// Do not delete it! Step 3 will fix it.
part 'weather_model.g.dart';

@JsonSerializable()
class WeatherModel {
  @JsonKey(name: 'main')
  final MainData mainData;

  @JsonKey(name: 'weather')
  final List<WeatherItem> weatherList;

  WeatherModel({
    required this.mainData,
    required this.weatherList,
  });

  // Helper getters so your UI doesn't have to dig through arrays
  int get roundedTemp => mainData.temp.round();
  String get condition => weatherList.isNotEmpty ? weatherList.first.main : 'Unknown';

  // The magic factory that json_serializable will hook into
  factory WeatherModel.fromJson(Map<String, dynamic> json) => _$WeatherModelFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherModelToJson(this);
}

// --------------------------------------------------------
// The OpenWeather API puts the temperature inside a "main" object
// --------------------------------------------------------
@JsonSerializable()
class MainData {
  final double temp;

  MainData({required this.temp});

  factory MainData.fromJson(Map<String, dynamic> json) => _$MainDataFromJson(json);
  Map<String, dynamic> toJson() => _$MainDataToJson(this);
}

// --------------------------------------------------------
// The OpenWeather API puts the condition inside a "weather" array
// --------------------------------------------------------
@JsonSerializable()
class WeatherItem {
  final String main;

  WeatherItem({required this.main});

  factory WeatherItem.fromJson(Map<String, dynamic> json) => _$WeatherItemFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherItemToJson(this);
}