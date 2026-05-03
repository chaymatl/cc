/// lib/services/firebase_score_service.dart
///
/// Service Firebase RTDB — écoute le score du citoyen en temps réel.
/// S'abonne au nœud /scores/{userId}/ dans Firebase Realtime Database
/// et expose un Stream mis à jour automatiquement dès qu'une poubelle
/// intelligente attribue des points.

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class ScoreSnapshot {
  final double total;
  final double lastPoints;
  final String lastBinType;
  final String lastScan;
  final String lastBinId;

  const ScoreSnapshot({
    required this.total,
    required this.lastPoints,
    required this.lastBinType,
    required this.lastScan,
    required this.lastBinId,
  });

  factory ScoreSnapshot.fromMap(Map<dynamic, dynamic> map) {
    return ScoreSnapshot(
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      lastPoints: (map['last_points'] as num?)?.toDouble() ?? 0.0,
      lastBinType: map['last_bin_type']?.toString() ?? 'general',
      lastScan: map['last_scan']?.toString() ?? '',
      lastBinId: map['last_bin_id']?.toString() ?? 'unknown',
    );
  }

  factory ScoreSnapshot.empty() => const ScoreSnapshot(
    total: 0.0,
    lastPoints: 0.0,
    lastBinType: 'general',
    lastScan: '',
    lastBinId: 'unknown',
  );
}

class FirebaseScoreService {
  static final FirebaseScoreService _instance = FirebaseScoreService._();
  factory FirebaseScoreService() => _instance;
  FirebaseScoreService._();

  final FirebaseDatabase _db = FirebaseDatabase.instance;
  StreamSubscription? _subscription;

  /// Écoute les mises à jour du score d'un citoyen en temps réel.
  /// Retourne un Stream<ScoreSnapshot> mis à jour par push Firebase.
  Stream<ScoreSnapshot> watchScore(int userId) {
    final ref = _db.ref('scores/$userId');
    return ref.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return ScoreSnapshot.empty();
      if (data is Map) {
        return ScoreSnapshot.fromMap(data as Map<dynamic, dynamic>);
      }
      return ScoreSnapshot.empty();
    });
  }

  /// Lit le score une seule fois (sans abonnement continu).
  Future<ScoreSnapshot> getScoreOnce(int userId) async {
    try {
      final ref = _db.ref('scores/$userId');
      final snapshot = await ref.get();
      if (!snapshot.exists || snapshot.value == null) return ScoreSnapshot.empty();
      return ScoreSnapshot.fromMap(snapshot.value as Map<dynamic, dynamic>);
    } catch (_) {
      return ScoreSnapshot.empty();
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
