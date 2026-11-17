import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_manager_repository.dart';
import '../../domain/entities/filter_entity.dart';

// --- THE STATE ---
class ManagerFilterState {
  final bool isLoading;
  final List<RegionEntity> allRegions;
  final RegionEntity? selectedRegion;
  final StationEntity? selectedStation;
  final GunEntity? selectedGun;
  final String? error;

  ManagerFilterState({
    this.isLoading = false,
    this.allRegions = const [],
    this.selectedRegion,
    this.selectedStation,
    this.selectedGun,
    this.error,
  });

  ManagerFilterState copyWith({
    bool? isLoading,
    List<RegionEntity>? allRegions,
    RegionEntity? selectedRegion,
    StationEntity? selectedStation,
    GunEntity? selectedGun,
    String? error,
    bool clearSelection = false,
  }) {
    return ManagerFilterState(
      isLoading: isLoading ?? this.isLoading,
      allRegions: allRegions ?? this.allRegions,
      selectedRegion: clearSelection ? null : (selectedRegion ?? this.selectedRegion),
      selectedStation: clearSelection ? null : (selectedStation ?? this.selectedStation),
      selectedGun: clearSelection ? null : (selectedGun ?? this.selectedGun),
      error: error,
    );
  }
}

// --- THE CUBIT ---
class ManagerFilterCubit extends Cubit<ManagerFilterState> {
  final IManagerRepository _repository;

  ManagerFilterCubit(this._repository) : super(ManagerFilterState());

  Future<void> loadFilters() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final regions = await _repository.getFilters();
      emit(state.copyWith(isLoading: false, allRegions: regions));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void selectSelection(RegionEntity region, StationEntity station, GunEntity gun) {
    emit(state.copyWith(
      selectedRegion: region,
      selectedStation: station,
      selectedGun: gun,
    ));
  }

  void clearSelection() {
    emit(state.copyWith(clearSelection: true));
  }
}