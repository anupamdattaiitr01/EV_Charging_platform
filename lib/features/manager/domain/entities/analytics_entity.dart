class TrendPointEntity {
  final String label;
  final double kwUsed;
  final double revenue;

  const TrendPointEntity({
    required this.label,
    required this.kwUsed,
    required this.revenue,
  });
}

class AnalyticsEntity {
  final String gunId;
  final int totalSessions;
  final double totalKwToday;
  final double totalRevenue;
  final double uptimePercentage;
  final List<TrendPointEntity> dailyTrends;
  final List<TrendPointEntity> monthlyTrends;

  const AnalyticsEntity({
    required this.gunId,
    required this.totalSessions,
    required this.totalKwToday,
    required this.totalRevenue,
    required this.uptimePercentage,
    this.dailyTrends = const [],
    this.monthlyTrends = const [],
  });
}