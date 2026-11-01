import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import the models you created in Phase 2
// Adjust this path if your file structure is different!
import '../models/analytics_model.dart';

// ============================================================================
// 1. STATES
// ============================================================================
abstract class AnalyticsState {}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final GunAnalytics data;
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
  AnalyticsCubit() : super(AnalyticsInitial());

  Future<void> loadAnalytics(String gunId) async {
    // 1. Tell the UI to show a loading spinner
    emit(AnalyticsLoading());

    try {
      // 2. Simulate a slight network delay so the loading UI feels realistic
      await Future.delayed(const Duration(milliseconds: 800));

      // 3. Read the dummy JSON file from the assets folder
      final String jsonString = await rootBundle.loadString('assets/data/gun_analytics.json');

      // 4. Decode the raw string into a Dart Map
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // 5. Convert the Map into our strongly-typed GunAnalytics model
      final GunAnalytics analyticsData = GunAnalytics.fromJson(jsonData);

      // 6. Tell the UI we have the data ready to paint!
      emit(AnalyticsLoaded(analyticsData));

    } catch (e) {
      // Catch any file reading or parsing errors
      emit(AnalyticsError("Failed to load analytics data: $e"));
    }
  }
}