import 'package:firebase_database/firebase_database.dart';
import '../../domain/entities/charging_session_entity.dart';
import '../models/charging_session_model.dart';

class ChargingRemoteDataSource {
  final List<ChargingSessionModel> _sessionStore = [
    const ChargingSessionModel(
      id: 'sess_101',
      stationName: 'ChargeOn Highway Hub',
      gunTitle: 'Gun A',
      connectorType: 'CCS2',
      powerRating: '60kW',
      dateGroup: 'Today',
      timestampLabel: '17 Nov 2026 - 06:42 PM',
      timeOnlyLabel: '06:42 PM',
      energyKwh: 18.5,
      durationFormatted: '42 Min 18 Sec',
      durationShort: '42 Min',
      energyCost: 333.00,
      taxes: 59.94,
      platformFee: 10.00,
      totalPaid: 402.94,
      remainingWalletBalance: 847.06,
      status: 'Completed',
    ),
    const ChargingSessionModel(
      id: 'sess_102',
      stationName: 'ChargeOn Cyber Hub',
      gunTitle: 'Gun B',
      connectorType: 'CCS2',
      powerRating: '60kW',
      dateGroup: 'Today',
      timestampLabel: '17 Nov 2026 - 11:15 AM',
      timeOnlyLabel: '11:15 AM',
      energyKwh: 14.2,
      durationFormatted: '31 Min 05 Sec',
      durationShort: '31 Min',
      energyCost: 255.60,
      taxes: 46.01,
      platformFee: 10.00,
      totalPaid: 311.61,
      remainingWalletBalance: 1250.00,
      status: 'Completed',
    ),
    const ChargingSessionModel(
      id: 'sess_103',
      stationName: 'ChargeOn Highway Hub',
      gunTitle: 'Gun A',
      connectorType: 'CCS2',
      powerRating: '60kW',
      dateGroup: 'Yesterday',
      timestampLabel: '16 Nov 2026 - 08:20 PM',
      timeOnlyLabel: '08:20 PM',
      energyKwh: 22.0,
      durationFormatted: '48 Min 10 Sec',
      durationShort: '48 Min',
      energyCost: 396.00,
      taxes: 71.28,
      platformFee: 10.00,
      totalPaid: 477.28,
      remainingWalletBalance: 1561.61,
      status: 'Completed',
    ),
    const ChargingSessionModel(
      id: 'sess_104',
      stationName: 'ChargeOn Metro Plaza',
      gunTitle: 'Gun D',
      connectorType: 'CCS2',
      powerRating: '60kW',
      dateGroup: 'Nov 14, 2026',
      timestampLabel: '14 Nov 2026 - 04:10 PM',
      timeOnlyLabel: '04:10 PM',
      energyKwh: 16.0,
      durationFormatted: '36 Min 00 Sec',
      durationShort: '36 Min',
      energyCost: 288.00,
      taxes: 51.84,
      platformFee: 10.00,
      totalPaid: 349.84,
      remainingWalletBalance: 2038.89,
      status: 'Completed',
    ),
  ];

  Future<List<ChargingGunEntity>> fetchGuns(String stationId) async {
    return const [
      ChargingGunEntity(
        id: 'A',
        title: 'Gun A',
        connector: 'CCS2',
        speed: '60kW DC',
        maxPowerKw: 60.0,
        statusText: 'Available',
        isAvailable: true,
      ),
      ChargingGunEntity(
        id: 'B',
        title: 'Gun B',
        connector: 'CCS2',
        speed: '60kW DC',
        maxPowerKw: 60.0,
        statusText: 'Available',
        isAvailable: true,
      ),
      ChargingGunEntity(
        id: 'C',
        title: 'Gun C',
        connector: 'CCS2',
        speed: '60kW DC',
        maxPowerKw: 60.0,
        statusText: 'In Use',
        isAvailable: false,
      ),
      ChargingGunEntity(
        id: 'D',
        title: 'Gun D',
        connector: 'CCS2',
        speed: '60kW DC',
        maxPowerKw: 60.0,
        statusText: 'Available',
        isAvailable: true,
      ),
    ];
  }

  Future<List<ChargingSessionModel>> fetchHistory() async {
    return List<ChargingSessionModel>.from(_sessionStore);
  }

  Future<void> insertSession(ChargingSessionModel model) async {
    _sessionStore.insert(0, model);
  }

  Stream<List<StationReviewEntity>> streamReviews(String stationId) {
    return FirebaseDatabase.instance
        .ref('station_reviews/$stationId')
        .onValue
        .map((DatabaseEvent event) {
      final rawValue = event.snapshot.value;
      if (rawValue == null || rawValue is! Map) {
        return <StationReviewEntity>[];
      }

      final reviews = rawValue.values.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return StationReviewEntity(
          text: map['text']?.toString() ?? '',
          videoUrl: map['videoUrl']?.toString() ?? '',
          audioUrl: map['audioUrl']?.toString() ?? '',
          timestamp: (map['timestamp'] as num?)?.toInt() ?? 0,
        );
      }).toList();

      reviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return reviews;
    });
  }
}