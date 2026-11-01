import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/manager_filter_models.dart';

// --- THE HIERARCHICAL STATE ---
class ManagerFilterState {
  final bool isLoading;
  final List<RegionModel> allRegions; // Keeps the nested structure intact
  final RegionModel? selectedRegion;
  final StationModel? selectedStation;
  final GunModel? selectedGun;

  ManagerFilterState({
    this.isLoading = false,
    this.allRegions = const [],
    this.selectedRegion,
    this.selectedStation,
    this.selectedGun,
  });

  ManagerFilterState copyWith({
    bool? isLoading,
    List<RegionModel>? allRegions,
    RegionModel? selectedRegion,
    StationModel? selectedStation,
    GunModel? selectedGun,
    bool clearSelection = false, // NEW: Flag to allow safely nullifying selections
  }) {
    return ManagerFilterState(
      isLoading: isLoading ?? this.isLoading,
      allRegions: allRegions ?? this.allRegions,

      // If clearSelection is true, force these to null. Otherwise, use passed or existing values.
      selectedRegion: clearSelection ? null : (selectedRegion ?? this.selectedRegion),
      selectedStation: clearSelection ? null : (selectedStation ?? this.selectedStation),
      selectedGun: clearSelection ? null : (selectedGun ?? this.selectedGun),
    );
  }
}

// --- THE CUBIT ---
class ManagerFilterCubit extends Cubit<ManagerFilterState> {
  ManagerFilterCubit() : super(ManagerFilterState());

  Future<void> loadFilters() async {
    emit(state.copyWith(isLoading: true));
    try {
      final String response = await rootBundle.loadString('assets/data/manager_filters.json');
      final data = await json.decode(response);

      var regionsList = data['taxonomy'] as List? ?? [];
      List<RegionModel> regions = regionsList.map((i) => RegionModel.fromJson(i)).toList();

      // No more flattening! Just pass the nested regions directly to the UI.
      emit(state.copyWith(isLoading: false, allRegions: regions));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      debugPrint("Error loading JSON taxonomy: $e");
    }
  }

  // Triggered when the final item (Gun) is clicked in the bottom sheet wizard
  void selectSelection(RegionModel region, StationModel station, GunModel gun) {
    emit(state.copyWith(
      selectedRegion: region,
      selectedStation: station,
      selectedGun: gun,
    ));
  }

  // --- NEW: Added ability to reset the dashboard filters ---
  void clearSelection() {
    emit(state.copyWith(clearSelection: true));
  }
}