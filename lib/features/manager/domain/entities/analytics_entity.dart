class AnalyticsEntity {
  final String gunId;
  final int totalSessions;
  final double totalRevenue;
  final double uptimePercentage;

  AnalyticsEntity({
    required this.gunId,
    required this.totalSessions,
    required this.totalRevenue,
    required this.uptimePercentage,
  });
}