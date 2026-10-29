import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/manager_filter_models.dart';

// --- 1. NEW FLATTENED HELPER CLASS ---
class FlatFilterItem {
  final String regionId;
  final String stationId;
  final GunModel gun;
  final String displayText;

  FlatFilterItem({
    required this.regionId,
    required this.stationId,
    required this.gun,
    required String regionTitle,
    required String stationTitle,
  }) : displayText = "$regionTitle  ➔  $stationTitle  ➔  ${gun.title}";
}

// --- 2. THE FLATTENED STATE ---
class ManagerFilterState {
  final bool isLoading;
  final List<FlatFilterItem> allItems; // The giant flattened list
  final FlatFilterItem? selectedItem;  // The single selection

  ManagerFilterState({
    this.isLoading = false,
    this.allItems = const [],
    this.selectedItem,
  });

  ManagerFilterState copyWith({
    bool? isLoading,
    List<FlatFilterItem>? allItems,
    FlatFilterItem? selectedItem,
  }) {
    return ManagerFilterState(
      isLoading: isLoading ?? this.isLoading,
      allItems: allItems ?? this.allItems,
      selectedItem: selectedItem ?? this.selectedItem,
    );
  }
}

// --- 3. THE CUBIT ---
class ManagerFilterCubit extends Cubit<ManagerFilterState> {
  ManagerFilterCubit() : super(ManagerFilterState());

  Future<void> loadFilters() async {
    emit(state.copyWith(isLoading: true));
    try {
      final String response = await rootBundle.loadString('assets/data/manager_filters.json');
      final data = await json.decode(response);

      var regionsList = data['taxonomy'] as List? ?? [];
      List<RegionModel> regions = regionsList.map((i) => RegionModel.fromJson(i)).toList();

      // FLATTEN THE DATA: Loop through every region, station, and gun
      List<FlatFilterItem> flatList = [];
      for (var region in regions) {
        for (var station in region.stations) {
          for (var gun in station.guns) {
            flatList.add(FlatFilterItem(
              regionId: region.id,
              stationId: station.id,
              gun: gun,
              regionTitle: region.title,
              stationTitle: station.title,
            ));
          }
        }
      }

      emit(state.copyWith(isLoading: false, allItems: flatList));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      debugPrint("Error loading JSON taxonomy: $e");
    }
  }

  void selectItem(FlatFilterItem? item) {
    emit(state.copyWith(selectedItem: item));
  }
}