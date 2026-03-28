import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tagme/features/location_sharing/data/repositories/live_location_repository.dart';

part 'live_location_providers.g.dart';

/// Provides a [LiveLocationRepository] backed by Firestore.
@riverpod
LiveLocationRepository liveLocationRepository(Ref ref) {
  return LiveLocationRepository(firestore: FirebaseFirestore.instance);
}

/// Streams a specific user's live location in a conversation.
@riverpod
Stream<Map<String, dynamic>?> partnerLiveLocation(
  Ref ref,
  String conversationId,
  String partnerId,
) {
  final repo = ref.watch(liveLocationRepositoryProvider);
  return repo.streamLiveLocation(
    conversationId: conversationId,
    userId: partnerId,
  );
}

/// Streams all active live locations for a conversation.
@riverpod
Stream<List<Map<String, dynamic>>> activeLiveLocations(
  Ref ref,
  String conversationId,
) {
  final repo = ref.watch(liveLocationRepositoryProvider);
  return repo.streamAllLiveLocations(conversationId: conversationId);
}
