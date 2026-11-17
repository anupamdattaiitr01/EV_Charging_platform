class ChargingGunEntity {
  final String id;
  final String title;
  final String connector;
  final String speed;
  final double maxPowerKw;
  final String statusText;
  final bool isAvailable;

  const ChargingGunEntity({
    required this.id,
    required this.title,
    required this.connector,
    required this.speed,
    required this.maxPowerKw,
    required this.statusText,
    required this.isAvailable,
  });
}

class ChargingSessionEntity {
  final String id;
  final String stationName;
  final String gunTitle;
  final String connectorType;
  final String powerRating;
  final String dateGroup;
  final String timestampLabel;
  final String timeOnlyLabel;
  final double energyKwh;
  final String durationFormatted;
  final String durationShort;
  final double energyCost;
  final double taxes;
  final double platformFee;
  final double totalPaid;
  final double remainingWalletBalance;
  final String status;

  const ChargingSessionEntity({
    required this.id,
    required this.stationName,
    required this.gunTitle,
    required this.connectorType,
    required this.powerRating,
    required this.dateGroup,
    required this.timestampLabel,
    required this.timeOnlyLabel,
    required this.energyKwh,
    required this.durationFormatted,
    required this.durationShort,
    required this.energyCost,
    required this.taxes,
    required this.platformFee,
    required this.totalPaid,
    required this.remainingWalletBalance,
    required this.status,
  });
}

class StationReviewEntity {
  final String text;
  final String videoUrl;
  final String audioUrl;
  final int timestamp;

  const StationReviewEntity({
    required this.text,
    required this.videoUrl,
    required this.audioUrl,
    required this.timestamp,
  });
}