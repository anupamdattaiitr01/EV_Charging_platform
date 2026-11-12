// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherModel _$WeatherModelFromJson(Map<String, dynamic> json) => WeatherModel(
  mainData: MainData.fromJson(json['main'] as Map<String, dynamic>),
  weatherList: (json['weather'] as List<dynamic>)
      .map((e) => WeatherItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$WeatherModelToJson(WeatherModel instance) =>
    <String, dynamic>{
      'main': instance.mainData,
      'weather': instance.weatherList,
    };

MainData _$MainDataFromJson(Map<String, dynamic> json) =>
    MainData(temp: (json['temp'] as num).toDouble());

Map<String, dynamic> _$MainDataToJson(MainData instance) => <String, dynamic>{
  'temp': instance.temp,
};

WeatherItem _$WeatherItemFromJson(Map<String, dynamic> json) =>
    WeatherItem(main: json['main'] as String);

Map<String, dynamic> _$WeatherItemToJson(WeatherItem instance) =>
    <String, dynamic>{'main': instance.main};
