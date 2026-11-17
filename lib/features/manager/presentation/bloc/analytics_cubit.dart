import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_manager_repository.dart';
import '../../domain/entities/analytics_entity.dart';

// ============================================================================
// 1. STATES
// ============================================================================
abstract class AnalyticsState {}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsEntity data;
  AnalyticsLoaded(this.data);
}

class AnalyticsError extends AnalyticsState {
  final String message;
  AnalyticsError(this.message);
}

// ============================================================================
// 2. CUBIT
// ============================================================================
class AnalyticsCubit extends Cubit<AnalyticsState> {
  final IManagerRepository _repository;

  AnalyticsCubit(this._repository) : super(AnalyticsInitial());

  Future<void> loadAnalytics(String gunId) async {
    emit(AnalyticsLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final AnalyticsEntity analyticsData = await _repository.getAnalytics(gunId);
      emit(AnalyticsLoaded(analyticsData));
    } catch (e) {
      emit(AnalyticsError("Failed to load analytics data: $e"));
    }
  }
}