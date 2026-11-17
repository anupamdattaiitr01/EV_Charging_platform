import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/charging_session_entity.dart';
import '../../domain/repositories/i_charging_repository.dart';

class ChargingState {
  final bool isLoading;
  final String stationId;
  final String stationName;
  final String stationSubtitle;
  final List<ChargingGunEntity> guns;
  final ChargingGunEntity? selectedGun;
  final bool isCharging;
  final double progress;
  final double currentPowerKw;
  final double energyDeliveredKwh;
  final double currentCost;
  final int elapsedSeconds;
  final int remainingSeconds;
  final ChargingSessionEntity? lastCompletedSession;
  final List<ChargingSessionEntity> allHistory;
  final String historySearchQuery;
  final String? errorMessage;

  const ChargingState({
    this.isLoading = false,
    this.stationId = 'chargeon_hub_1',
    this.stationName = 'ChargeOn Highway Hub',
    this.stationSubtitle = '2 Charging Points • 60kW',
    this.guns = const [],
    this.selectedGun,
    this.isCharging = false,
    this.progress = 0.68,
    this.currentPowerKw = 58.0,
    this.energyDeliveredKwh = 12.4,
    this.currentCost = 223.20,
    this.elapsedSeconds = 1104, // 00:18:24
    this.remainingSeconds = 1930, // 00:32:10
    this.lastCompletedSession,
    this.allHistory = const [],
    this.historySearchQuery = '',
    this.errorMessage,
  });

  List<ChargingSessionEntity> get filteredHistory {
    if (historySearchQuery.trim().isEmpty) return allHistory;
    final query = historySearchQuery.toLowerCase();
    return allHistory
        .where((s) =>
    s.stationName.toLowerCase().contains(query) ||
        s.gunTitle.toLowerCase().contains(query) ||
        s.dateGroup.toLowerCase().contains(query))
        .toList();
  }

  String get formattedElapsed => _formatHms(elapsedSeconds);
  String get formattedRemaining => _formatHms(remainingSeconds);

  static String _formatHms(int totalSeconds) {
    final safe = totalSeconds < 0 ? 0 : totalSeconds;
    final hours = (safe ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((safe % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (safe % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  ChargingState copyWith({
    bool? isLoading,
    String? stationId,
    String? stationName,
    String? stationSubtitle,
    List<ChargingGunEntity>? guns,
    ChargingGunEntity? selectedGun,
    bool? isCharging,
    double? progress,
    double? currentPowerKw,
    double? energyDeliveredKwh,
    double? currentCost,
    int? elapsedSeconds,
    int? remainingSeconds,
    ChargingSessionEntity? lastCompletedSession,
    List<ChargingSessionEntity>? allHistory,
    String? historySearchQuery,
    String? errorMessage,
  }) {
    return ChargingState(
      isLoading: isLoading ?? this.isLoading,
      stationId: stationId ?? this.stationId,
      stationName: stationName ?? this.stationName,
      stationSubtitle: stationSubtitle ?? this.stationSubtitle,
      guns: guns ?? this.guns,
      selectedGun: selectedGun ?? this.selectedGun,
      isCharging: isCharging ?? this.isCharging,
      progress: progress ?? this.progress,
      currentPowerKw: currentPowerKw ?? this.currentPowerKw,
      energyDeliveredKwh: energyDeliveredKwh ?? this.energyDeliveredKwh,
      currentCost: currentCost ?? this.currentCost,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      lastCompletedSession: lastCompletedSession ?? this.lastCompletedSession,
      allHistory: allHistory ?? this.allHistory,
      historySearchQuery: historySearchQuery ?? this.historySearchQuery,
      errorMessage: errorMessage,
    );
  }
}

class ChargingCubit extends Cubit<ChargingState> {
  final IChargingRepository _repository;
  Timer? _sessionTimer;

  ChargingCubit(this._repository) : super(const ChargingState());

  Future<void> loadInitialData() async {
    if (state.guns.isNotEmpty && state.allHistory.isNotEmpty) return;

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final guns = await _repository.getAvailableGuns(state.stationId);
      final history = await _repository.getChargingHistory();
      emit(state.copyWith(
        isLoading: false,
        guns: guns,
        allHistory: history,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void selectGun(ChargingGunEntity gun) {
    if (!gun.isAvailable) return;
    emit(state.copyWith(selectedGun: gun));
  }

  void startChargingSession() {
    if (state.isCharging) return;

    _sessionTimer?.cancel();
    emit(state.copyWith(
      isCharging: true,
      progress: 0.68,
      currentPowerKw: 58.0,
      energyDeliveredKwh: 12.4,
      currentCost: 223.20,
      elapsedSeconds: 1104,
      remainingSeconds: 1930,
    ));

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final nextElapsed = state.elapsedSeconds + 1;
      final nextRemaining = (state.remainingSeconds - 1).clamp(0, 99999);
      final nextEnergy = double.parse((state.energyDeliveredKwh + 0.016).toStringAsFixed(2));
      final nextCost = double.parse((nextEnergy * 18.0).toStringAsFixed(2));
      final nextProgress = (state.progress + 0.001).clamp(0.0, 1.0);

      emit(state.copyWith(
        elapsedSeconds: nextElapsed,
        remainingSeconds: nextRemaining,
        energyDeliveredKwh: nextEnergy,
        currentCost: nextCost,
        progress: nextProgress,
      ));
    });
  }

  Future<void> stopChargingSession() async {
    _sessionTimer?.cancel();
    _sessionTimer = null;

    final energyCost = double.parse(state.currentCost.toStringAsFixed(2));
    final taxes = double.parse((energyCost * 0.18).toStringAsFixed(2));
    const platformFee = 10.00;
    final totalPaid = double.parse((energyCost + taxes + platformFee).toStringAsFixed(2));
    final mins = state.elapsedSeconds ~/ 60;
    final secs = state.elapsedSeconds % 60;

    final completed = ChargingSessionEntity(
      id: 'sess_${DateTime.now().millisecondsSinceEpoch}',
      stationName: state.stationName,
      gunTitle: state.selectedGun?.title ?? 'Gun A',
      connectorType: state.selectedGun?.connector ?? 'CCS2',
      powerRating: state.selectedGun?.speed ?? '60kW',
      dateGroup: 'Today',
      timestampLabel: '17 Nov 2026 - Just Now',
      timeOnlyLabel: 'Just Now',
      energyKwh: state.energyDeliveredKwh,
      durationFormatted: '$mins Min ${secs.toString().padLeft(2, '0')} Sec',
      durationShort: '$mins Min',
      energyCost: energyCost,
      taxes: taxes,
      platformFee: platformFee,
      totalPaid: totalPaid,
      remainingWalletBalance: double.parse((1250.00 - totalPaid).clamp(0.0, 99999.0).toStringAsFixed(2)),
      status: 'Completed',
    );

    await _repository.saveCompletedSession(completed);
    final updatedHistory = await _repository.getChargingHistory();

    emit(state.copyWith(
      isCharging: false,
      lastCompletedSession: completed,
      allHistory: updatedHistory,
    ));
  }

  void updateHistorySearch(String query) {
    emit(state.copyWith(historySearchQuery: query));
  }

  Stream<List<StationReviewEntity>> watchReviews(String stationId) {
    return _repository.watchStationReviews(stationId);
  }

  @override
  Future<void> close() {
    _sessionTimer?.cancel();
    return super.close();
  }
}