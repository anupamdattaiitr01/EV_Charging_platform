import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/i_weather_repository.dart';

// --- 1. THE STATE ---
class DashboardState {
  final String vehicleName;
  final String temperature;
  final String weatherCondition;
  final IconData weatherIcon;
  final int selectedNavIndex;
  final Set<int> loadedIndices;
  final bool isCharging;

  DashboardState({
    this.vehicleName = "Loading...",
    this.temperature = "--°C",
    this.weatherCondition = "Loading...",
    this.weatherIcon = Icons.cloud_outlined,
    this.selectedNavIndex = 0,
    this.loadedIndices = const {0},
    this.isCharging = false,
  });

  DashboardState copyWith({
    String? vehicleName,
    String? temperature,
    String? weatherCondition,
    IconData? weatherIcon,
    int? selectedNavIndex,
    Set<int>? loadedIndices,
    bool? isCharging,
  }) {
    return DashboardState(
      vehicleName: vehicleName ?? this.vehicleName,
      temperature: temperature ?? this.temperature,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      weatherIcon: weatherIcon ?? this.weatherIcon,
      selectedNavIndex: selectedNavIndex ?? this.selectedNavIndex,
      loadedIndices: loadedIndices ?? this.loadedIndices,
      isCharging: isCharging ?? this.isCharging,
    );
  }
}

// --- 2. THE CUBIT ---
class DashboardCubit extends Cubit<DashboardState> {
  // Inject the repository instead of the API client directly
  final IWeatherRepository _weatherRepository;

  DashboardCubit(this._weatherRepository) : super(DashboardState()) {
    _loadVehicleDetails();
    _fetchWeather();
  }

  Future<void> _loadVehicleDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String brand = prefs.getString('car_brand') ?? "Tata";
    final String model = prefs.getString('car_model') ?? "Nexon EV";

    emit(state.copyWith(vehicleName: "$brand $model"));
  }

  Future<void> _fetchWeather() async {
    // 1. Ask the Repository for the domain Entity
    final weatherData = await _weatherRepository.getWeather(28.4354, 77.0823);

    if (weatherData == null) {
      emit(state.copyWith(weatherCondition: "Offline"));
      return;
    }

    // 2. Map the condition to an Icon
    IconData icon = Icons.wb_cloudy;
    final conditionLower = weatherData.condition.toLowerCase();

    if (conditionLower.contains('cloud')) {
      icon = Icons.cloud;
    } else if (conditionLower.contains('rain') || conditionLower.contains('drizzle')) {
      icon = Icons.water_drop;
    } else if (conditionLower.contains('clear')) {
      icon = Icons.wb_sunny;
    } else if (conditionLower.contains('thunder')) {
      icon = Icons.thunderstorm;
    }

    // 3. Update the State
    emit(state.copyWith(
      temperature: weatherData.temperature,
      weatherCondition: weatherData.condition,
      weatherIcon: icon,
    ));
  }

  void changeTab(int index) {
    final newIndices = Set<int>.from(state.loadedIndices)..add(index);
    emit(state.copyWith(selectedNavIndex: index, loadedIndices: newIndices));
  }

  void setChargingStatus(bool isCharging) {
    emit(state.copyWith(isCharging: isCharging));
  }
}