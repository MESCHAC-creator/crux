import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

/// Scalability Management Service
/// Handles automatic routing to appropriate SFU based on participant count
class ScalabilityService {
  static final ScalabilityService _instance = ScalabilityService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _log = Logger();

  factory ScalabilityService() => _instance;
  ScalabilityService._internal();

  // SFU Configurations
  static const int AGORA_THRESHOLD_SMALL = 50;
  static const int AGORA_THRESHOLD_MEDIUM = 300;
  static const int JITSI_THRESHOLD_LARGE = 1000;

  /// Determine optimal SFU based on participant count
  Future<SFUConfiguration> determineSFU(String meetingId) async {
    try {
      final meetingSnap = await _firestore.collection('meetings')
          .doc(meetingId).get();
      
      if (!meetingSnap.exists) {
        throw Exception('Meeting not found');
      }

      final participantCount = (meetingSnap['participants'] as List?)?.length ?? 0;
      final isLargeConference = meetingSnap['isLargeConference'] as bool? ?? false;

      SFUConfiguration config;

      if (participantCount <= AGORA_THRESHOLD_SMALL && !isLargeConference) {
        config = SFUConfiguration.agora(tier: 'starter');
        _log.i('✅ Routing to Agora (small: $participantCount participants)');
      } else if (participantCount <= AGORA_THRESHOLD_MEDIUM && !isLargeConference) {
        config = SFUConfiguration.agora(tier: 'professional');
        _log.i('✅ Routing to Agora (medium: $participantCount participants)');
      } else {
        config = SFUConfiguration.jitsi(tier: 'scalable');
        _log.i('✅ Routing to Jitsi SFU (large: $participantCount participants)');
      }

      // Store config in Firestore
      await _firestore.collection('meetings').doc(meetingId).update({
        'sfuConfiguration': config.toJson(),
        'participantCount': participantCount,
        'lastRoutedAt': FieldValue.serverTimestamp(),
      });

      return config;
    } catch (e) {
      _log.e('determineSFU failed: $e');
      rethrow;
    }
  }

  /// Monitor participant count and trigger migration if needed
  Stream<ScalabilityStatus> monitorScalability(String meetingId) {
    return _firestore.collection('meetings').doc(meetingId)
        .snapshots()
        .asyncMap((snap) async {
          if (!snap.exists) {
            return ScalabilityStatus(
              meetingId: meetingId,
              participantCount: 0,
              currentSFU: 'none',
              recommendedSFU: 'none',
              migrationNeeded: false,
            );
          }

          final data = snap.data()!;
          final participantCount = (data['participants'] as List?)?.length ?? 0;
          final currentSFU = data['sfuConfiguration']?['provider'] ?? 'agora';

          // Determine recommended SFU
          String recommendedSFU;
          if (participantCount <= AGORA_THRESHOLD_SMALL) {
            recommendedSFU = 'agora_starter';
          } else if (participantCount <= AGORA_THRESHOLD_MEDIUM) {
            recommendedSFU = 'agora_professional';
          } else {
            recommendedSFU = 'jitsi_scalable';
          }

          final migrationNeeded = currentSFU != recommendedSFU;

          if (migrationNeeded) {
            _log.w('⚠️ Migration needed: $currentSFU → $recommendedSFU '
                '(participants: $participantCount)');
          }

          return ScalabilityStatus(
            meetingId: meetingId,
            participantCount: participantCount,
            currentSFU: currentSFU,
            recommendedSFU: recommendedSFU,
            migrationNeeded: migrationNeeded,
          );
        });
  }

  /// Migrate meeting to different SFU (zero-downtime if possible)
  Future<bool> migrateSFU({
    required String meetingId,
    required String newSFU,
  }) async {
    try {
      _log.i('🔄 Initiating SFU migration to: $newSFU');

      // Step 1: Create new SFU instance
      final newConfig = _createSFUConfig(newSFU);

      // Step 2: Update Firestore (metadata only, no media interruption)
      await _firestore.collection('meetings').doc(meetingId).update({
        'migration': {
          'status': 'in_progress',
          'fromSFU': FieldValue.delete(), // Get current value first
          'toSFU': newSFU,
          'startedAt': FieldValue.serverTimestamp(),
        },
      });

      // Step 3: Graceful participant reconnection
      // In production: send reconnection signal to clients
      await _firestore.collection('meetings').doc(meetingId)
          .collection('presence').doc('_migration_signal_').set({
        'type': 'sfu_migration',
        'newSFU': newSFU,
        'newConfig': newConfig.toJson(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Step 4: Wait for all participants to reconnect (30 second timeout)
      await Future.delayed(const Duration(seconds: 30));

      // Step 5: Complete migration
      await _firestore.collection('meetings').doc(meetingId).update({
        'sfuConfiguration': newConfig.toJson(),
        'migration': {
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
        },
      });

      _log.i('✅ SFU migration completed: $newSFU');
      return true;
    } catch (e) {
      _log.e('migrateSFU failed: $e');
      return false;
    }
  }

  /// Get current scalability metrics
  Future<ScalabilityMetrics> getMetrics(String meetingId) async {
    try {
      final snap = await _firestore.collection('meetings').doc(meetingId).get();
      
      if (!snap.exists) {
        throw Exception('Meeting not found');
      }

      final data = snap.data()!;
      final participantCount = (data['participants'] as List?)?.length ?? 0;
      final estimatedBandwidth = participantCount * 2.5; // Mbps per participant

      return ScalabilityMetrics(
        meetingId: meetingId,
        participantCount: participantCount,
        estimatedBandwidth: estimatedBandwidth,
        estimatedCost: _estimateCost(participantCount, data['duration'] ?? 0),
        cpuUtilization: _estimateCPU(participantCount),
        networkLatency: _estimateLatency(participantCount),
      );
    } catch (e) {
      _log.e('getMetrics failed: $e');
      rethrow;
    }
  }

  /// Helper: Create SFU configuration
  SFUConfiguration _createSFUConfig(String sfuName) {
    if (sfuName.startsWith('agora')) {
      final tier = sfuName.contains('starter') ? 'starter' : 'professional';
      return SFUConfiguration.agora(tier: tier);
    } else {
      return SFUConfiguration.jitsi(tier: 'scalable');
    }
  }

  /// Helper: Estimate cost
  double _estimateCost(int participantCount, int durationSeconds) {
    double costPerMinute = 0.0;

    if (participantCount <= 50) {
      costPerMinute = 0.002; // $0.002/min/participant
    } else if (participantCount <= 300) {
      costPerMinute = 0.004; // $0.004/min/participant
    } else {
      costPerMinute = 0.010; // $0.010/min/participant (Jitsi managed)
    }

    return (participantCount * costPerMinute * durationSeconds) / 60;
  }

  /// Helper: Estimate CPU utilization
  double _estimateCPU(int participantCount) {
    return (participantCount / 1000) * 100; // Rough estimate
  }

  /// Helper: Estimate network latency
  int _estimateLatency(int participantCount) {
    if (participantCount <= 50) return 50;
    if (participantCount <= 300) return 100;
    return 200;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// MODELS
// ═════════════════════════════════════════════════════════════════════════════

class SFUConfiguration {
  final String provider; // 'agora', 'jitsi'
  final String tier; // 'starter', 'professional', 'scalable'
  final String appId;
  final String signingKey;
  final List<String> serverRegions;
  final int maxParticipants;
  final double maxBandwidth; // Mbps
  final int latencyThreshold; // ms

  SFUConfiguration({
    required this.provider,
    required this.tier,
    required this.appId,
    required this.signingKey,
    required this.serverRegions,
    required this.maxParticipants,
    required this.maxBandwidth,
    required this.latencyThreshold,
  });

  factory SFUConfiguration.agora({String tier = 'starter'}) {
    final maxParticipants = tier == 'starter' ? 50 : 300;
    return SFUConfiguration(
      provider: 'agora',
      tier: tier,
      appId: 'AGORA_APP_ID', // From env
      signingKey: 'AGORA_SIGNING_KEY',
      serverRegions: ['us', 'eu', 'asia'],
      maxParticipants: maxParticipants,
      maxBandwidth: 50.0,
      latencyThreshold: 100,
    );
  }

  factory SFUConfiguration.jitsi({String tier = 'scalable'}) {
    return SFUConfiguration(
      provider: 'jitsi',
      tier: tier,
      appId: 'JITSI_APP_ID',
      signingKey: 'JITSI_KEY',
      serverRegions: ['us', 'eu', 'asia', 'oceania'],
      maxParticipants: 1000,
      maxBandwidth: 300.0,
      latencyThreshold: 500,
    );
  }

  Map<String, dynamic> toJson() => {
    'provider': provider,
    'tier': tier,
    'appId': appId,
    'serverRegions': serverRegions,
    'maxParticipants': maxParticipants,
    'maxBandwidth': maxBandwidth,
    'latencyThreshold': latencyThreshold,
  };
}

class ScalabilityStatus {
  final String meetingId;
  final int participantCount;
  final String currentSFU;
  final String recommendedSFU;
  final bool migrationNeeded;

  ScalabilityStatus({
    required this.meetingId,
    required this.participantCount,
    required this.currentSFU,
    required this.recommendedSFU,
    required this.migrationNeeded,
  });
}

class ScalabilityMetrics {
  final String meetingId;
  final int participantCount;
  final double estimatedBandwidth; // Mbps
  final double estimatedCost; // USD
  final double cpuUtilization; // %
  final int networkLatency; // ms

  ScalabilityMetrics({
    required this.meetingId,
    required this.participantCount,
    required this.estimatedBandwidth,
    required this.estimatedCost,
    required this.cpuUtilization,
    required this.networkLatency,
  });
}
