import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

/// Repository handling Firestore CRUD for live location sharing.
///
/// Stores live location documents in a `liveLocations` subcollection
/// under each conversation. One document per user (overwrite, not append).
class LiveLocationRepository {
  LiveLocationRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Writes or overwrites the user's live location document in the
  /// liveLocations subcollection. Single doc per user (overwrite, not append).
  Future<void> updateLiveLocation({
    required String conversationId,
    required String userId,
    required double latitude,
    required double longitude,
    required double accuracy,
  }) async {
    final expiresAt = DateTime.now().add(const Duration(minutes: 30));
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('liveLocations')
        .doc(userId)
        .set({
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'updatedAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isActive': true,
    });
  }

  /// Streams a specific user's live location document.
  /// Returns null-mapped snapshots when document doesn't exist.
  Stream<Map<String, dynamic>?> streamLiveLocation({
    required String conversationId,
    required String userId,
  }) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('liveLocations')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  /// Streams all active live location documents for a conversation.
  Stream<List<Map<String, dynamic>>> streamAllLiveLocations({
    required String conversationId,
  }) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('liveLocations')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
        );
  }

  /// Sets isActive to false to stop sharing.
  Future<void> stopSharing({
    required String conversationId,
    required String userId,
  }) async {
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('liveLocations')
        .doc(userId)
        .update({'isActive': false});
  }
}

/// Throttled GPS writer that limits Firestore writes to once per 10 seconds
/// minimum.
///
/// Uses geolocator distanceFilter (10m) on the stream side, plus time-based
/// debounce here. This prevents excessive Firestore writes when the user is
/// moving rapidly.
class ThrottledLocationWriter {
  ThrottledLocationWriter({required this.repository});

  final LiveLocationRepository repository;

  Timer? _throttleTimer;
  Position? _lastPosition;
  DateTime? _lastWriteTime;
  static const _minInterval = Duration(seconds: 10);

  /// Called on each geolocator position update.
  /// Throttles Firestore writes to max once per 10 seconds.
  void onPositionUpdate(
    Position position, {
    required String conversationId,
    required String userId,
  }) {
    _lastPosition = position;
    final now = DateTime.now();
    if (_lastWriteTime == null ||
        now.difference(_lastWriteTime!) >= _minInterval) {
      _writePosition(conversationId, userId, position);
      _lastWriteTime = now;
    } else {
      _throttleTimer?.cancel();
      _throttleTimer = Timer(
        _minInterval - now.difference(_lastWriteTime!),
        () {
          if (_lastPosition != null) {
            _writePosition(conversationId, userId, _lastPosition!);
          }
        },
      );
    }
  }

  Future<void> _writePosition(
    String conversationId,
    String userId,
    Position position,
  ) async {
    _lastWriteTime = DateTime.now();
    await repository.updateLiveLocation(
      conversationId: conversationId,
      userId: userId,
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
    );
  }

  /// Cancels pending throttle timer. Call when stopping live sharing.
  void dispose() {
    _throttleTimer?.cancel();
  }
}
