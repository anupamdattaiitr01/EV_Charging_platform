import 'dart:convert';
import 'package:flutter/services.dart';

typedef JsonMap = Map<String, dynamic>;

class ManagerRemoteDataSource {
  Future<JsonMap> fetchFilters() async {
    final String response = await rootBundle.loadString('assets/data/manager_filters.json');
    return json.decode(response) as JsonMap;
  }

  Future<JsonMap> fetchAnalytics(String gunId) async {
    final String response = await rootBundle.loadString('assets/data/gun_analytics.json');
    return json.decode(response) as JsonMap;
  }
}