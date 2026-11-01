class GunAnalytics {
  final String gunId;
  final AnalyticsSummary summary;
  final List<TrendData> dailyTrends;
  final List<TrendData> monthlyTrends;

  GunAnalytics({
    required this.gunId,
    required this.summary,
    required this.dailyTrends,
    required this.monthlyTrends,
  });

  factory GunAnalytics.fromJson(Map<String, dynamic> json) {
    return GunAnalytics(
      gunId: json['gun_id'] ?? '',
      summary: AnalyticsSummary.fromJson(json['summary'] ?? {}),
      dailyTrends: (json['daily_trends'] as List<dynamic>?)
          ?.map((e) => TrendData.fromJson(e))
          .toList() ??
          [],
      monthlyTrends: (json['monthly_trends'] as List<dynamic>?)
          ?.map((e) => TrendData.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class AnalyticsSummary {
  final int totalCarsToday;
  final double totalKwToday;
  final double revenueToday;
  final double hoursActiveToday;

  AnalyticsSummary({
    required this.totalCarsToday,
    required this.totalKwToday,
    required this.revenueToday,
    required this.hoursActiveToday,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      totalCarsToday: json['total_cars_today'] ?? 0,
      totalKwToday: (json['total_kw_today'] ?? 0).toDouble(),
      revenueToday: (json['revenue_today'] ?? 0).toDouble(),
      hoursActiveToday: (json['hours_active_today'] ?? 0).toDouble(),
    );
  }
}

class TrendData {
  final String label;
  final double kwUsed;
  final double revenue;

  TrendData({
    required this.label,
    required this.kwUsed,
    required this.revenue,
  });

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      label: json['label'] ?? '',
      kwUsed: (json['kw_used'] ?? 0).toDouble(),
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}