import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// All the Bloc States
abstract class VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleLoaded extends VehicleState {
  final String? selectedBrand;
  final String? selectedModel;
  final String? selectedConnector;

  VehicleLoaded({
    this.selectedBrand,
    this.selectedModel,
    this.selectedConnector,
  });

  VehicleLoaded copyWith({
    String? selectedBrand,
    String? selectedModel,
    bool resetModel = false,
    String? selectedConnector,
  }) {
    return VehicleLoaded(
      selectedBrand: selectedBrand ?? this.selectedBrand,
      selectedModel: resetModel ? null : (selectedModel ?? this.selectedModel),
      selectedConnector: selectedConnector ?? this.selectedConnector,
    );
  }
}

class VehicleSaved extends VehicleState {}

class VehicleError extends VehicleState {
  final String message;
  final VehicleLoaded previousState;

  VehicleError(this.message, this.previousState);
}

// This is the actual Cubit
class VehicleCubit extends Cubit<VehicleState> {

  // String declaration to reduce the silent Error in the code
  // These are all the keys that are declared to ensure the mistype of the key string
  // This avoids the silent injestion of the error in the code
  static const String _brandKey = 'car_brand';
  static const String _modelKey = 'car_model';
  static const String _connectorKey = 'car_connector';

  VehicleCubit() : super(VehicleLoading()) {
    loadSavedVehicle();
  }

  Future<void> loadSavedVehicle() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    emit(VehicleLoaded(
      selectedBrand: prefs.getString(_brandKey),
      selectedModel: prefs.getString(_modelKey),
      selectedConnector: prefs.getString(_connectorKey),
    ));
  }

  void updateBrand(String brand) {
    if (state is VehicleLoaded) {
      final current = state as VehicleLoaded;
      emit(current.copyWith(selectedBrand: brand, resetModel: true));
    }
  }

  void updateModel(String model) {
    if (state is VehicleLoaded) {
      final current = state as VehicleLoaded;
      emit(current.copyWith(selectedModel: model));
    }
  }

  void updateConnector(String connector) {
    if (state is VehicleLoaded) {
      final current = state as VehicleLoaded;
      emit(current.copyWith(selectedConnector: connector));
    }
  }

  Future<void> saveVehicle() async {
    if (state is VehicleLoaded) {
      final current = state as VehicleLoaded;

      if (current.selectedBrand == null ||
          current.selectedModel == null ||
          current.selectedConnector == null) {
        emit(VehicleError("Please select all vehicle details", current));
        emit(current);
        return;
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_brandKey, current.selectedBrand!);
      await prefs.setString(_modelKey, current.selectedModel!);
      await prefs.setString(_connectorKey, current.selectedConnector!);

      emit(VehicleSaved());
    }
  }
}