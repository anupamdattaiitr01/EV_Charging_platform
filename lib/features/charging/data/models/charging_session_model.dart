import '../../domain/entities/charging_session_entity.dart';

class ChargingSessionModel extends ChargingSessionEntity {
  const ChargingSessionModel({
    required super.id,
    required super.stationName,
    required super.gunTitle,
    required super.connectorType,
    required super.powerRating,
    required super.dateGroup,
    required super.timestampLabel,
    required super.timeOnlyLabel,
    required super.energyKwh,
    required super.durationFormatted,
    required super.durationShort,
    required super.energyCost,
    required super.taxes,
    required super.platformFee,
    required super.totalPaid,
    required super.remainingWalletBalance,
    required super.status,
  });

  factory ChargingSessionModel.fromEntity(ChargingSessionEntity entity) {
    return ChargingSessionModel(
      id: entity.id,
      stationName: entity.stationName,
      gunTitle: entity.gunTitle,
      connectorType: entity.connectorType,
      powerRating: entity.powerRating,
      dateGroup: entity.dateGroup,
      timestampLabel: entity.timestampLabel,
      timeOnlyLabel: entity.timeOnlyLabel,
      energyKwh: entity.energyKwh,
      durationFormatted: entity.durationFormatted,
      durationShort: entity.durationShort,
      energyCost: entity.energyCost,
      taxes: entity.taxes,
      platformFee: entity.platformFee,
      totalPaid: entity.totalPaid,
      remainingWalletBalance: entity.remainingWalletBalance,
      status: entity.status,
    );
  }

  factory ChargingSessionModel.fromJson(Map<String, dynamic> json) {
    return ChargingSessionModel(
      id: json['id'] as String? ?? '',
      stationName: json['stationName'] as String? ?? 'ChargeOn Highway Hub',
      gunTitle: json['gunTitle'] as String? ?? 'Gun A',
      connectorType: json['connectorType'] as String? ?? 'CCS2',
      powerRating: json['powerRating'] as String? ?? '60kW DC',
      dateGroup: json['dateGroup'] as String? ?? 'Today',
      timestampLabel: json['timestampLabel'] as String? ?? '',
      timeOnlyLabel: json['timeOnlyLabel'] as String? ?? '',
      energyKwh: (json['energyKwh'] as num?)?.toDouble() ?? 0.0,
      durationFormatted: json['durationFormatted'] as String? ?? '0 Min',
      durationShort: json['durationShort'] as String? ?? '0 Min',
      energyCost: (json['energyCost'] as num?)?.toDouble() ?? 0.0,
      taxes: (json['taxes'] as num?)?.toDouble() ?? 0.0,
      platformFee: (json['platformFee'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
      remainingWalletBalance: (json['remainingWalletBalance'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'Completed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stationName': stationName,
      'gunTitle': gunTitle,
      'connectorType': connectorType,
      'powerRating': powerRating,
      'dateGroup': dateGroup,
      'timestampLabel': timestampLabel,
      'timeOnlyLabel': timeOnlyLabel,
      'energyKwh': energyKwh,
      'durationFormatted': durationFormatted,
      'durationShort': durationShort,
      'energyCost': energyCost,
      'taxes': taxes,
      'platformFee': platformFee,
      'totalPaid': totalPaid,
      'remainingWalletBalance': remainingWalletBalance,
      'status': status,
    };
  }
}