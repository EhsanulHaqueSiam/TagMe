import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tagme/features/chat/data/repositories/chat_repository.dart';
import 'package:tagme/features/rides/data/models/join_request.dart';

part 'join_request_repository.g.dart';

/// Repository handling Firestore CRUD for join requests.
///
/// Uses a top-level `joinRequests` collection (NOT subcollection) to allow
/// querying across all rides efficiently.
@riverpod
JoinRequestRepository joinRequestRepository(Ref ref) {
  return JoinRequestRepository(firestore: FirebaseFirestore.instance);
}

class JoinRequestRepository {
  JoinRequestRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _requestsCollection =>
      _firestore.collection('joinRequests');

  /// Creates a new join request. Returns the auto-generated doc ID.
  Future<String> createRequest(JoinRequest request) async {
    final data = request.toJson();
    data.remove('id');
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    final docRef = await _requestsCollection.add(data);
    return docRef.id;
  }

  /// Streams join requests for a specific ride, ordered by creation time.
  Stream<List<JoinRequest>> requestsForRide(String rideId) {
    return _requestsCollection
        .where('rideId', isEqualTo: rideId)
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(_requestFromDoc).toList(),
        );
  }

  /// Streams join requests created by a specific student.
  Stream<List<JoinRequest>> myRequests(String studentId) {
    return _requestsCollection
        .where('requesterId', isEqualTo: studentId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(_requestFromDoc).toList(),
        );
  }

  /// Accepts a join request using a Firestore transaction.
  ///
  /// Atomically: reads the ride doc, checks seat availability, increments
  /// filledSeats, sets ride to 'full' if needed, updates request status, and
  /// adds the rider to the `rides/{rideId}/riders` subcollection.
  /// After the transaction, creates a chat conversation between the two users.
  Future<void> acceptRequest(
    String requestId,
    String rideId, {
    required String posterName,
    required String posterUniversity,
    required String rideOrigin,
    required String rideDestination,
    required String rideTransportType,
    required DateTime rideDepartureTime,
  }) async {
    // Variables extracted from transaction for post-transaction use.
    String? posterId;
    String? requesterId;
    String? requesterName;
    String? requesterUniversity;

    await _firestore.runTransaction((transaction) async {
      // Read ride document.
      final rideRef = _firestore.collection('rides').doc(rideId);
      final rideDoc = await transaction.get(rideRef);
      if (!rideDoc.exists) throw Exception('Ride not found');

      final rideData = rideDoc.data()!;
      posterId = rideData['posterId'] as String?;
      final filledSeats = (rideData['filledSeats'] as num?)?.toInt() ?? 0;
      final totalSeats = (rideData['totalSeats'] as num?)?.toInt() ?? 0;

      if (filledSeats >= totalSeats) {
        throw Exception('Ride is full');
      }

      final newFilledSeats = filledSeats + 1;
      final updates = <String, dynamic>{
        'filledSeats': newFilledSeats,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (newFilledSeats >= totalSeats) {
        updates['status'] = 'full';
      }
      transaction.update(rideRef, updates);

      // Update request status to accepted.
      final requestRef = _requestsCollection.doc(requestId);
      transaction.update(requestRef, {
        'status': 'accepted',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Read requester info from the request document.
      final requestDoc = await transaction.get(requestRef);
      final requestData = requestDoc.data();

      requesterId = requestData?['requesterId'] as String?;
      requesterName = requestData?['requesterName'] as String?;
      requesterUniversity = requestData?['requesterUniversity'] as String?;

      // Add rider to subcollection.
      final riderRef = rideRef.collection('riders').doc(requesterId);
      transaction.set(riderRef, {
        'requesterId': requestData?['requesterId'],
        'requesterName': requestData?['requesterName'],
        'requesterUniversity': requestData?['requesterUniversity'],
        'requesterPhotoUrl': requestData?['requesterPhotoUrl'],
        'joinedAt': FieldValue.serverTimestamp(),
      });
    });

    // Create conversation AFTER transaction completes successfully.
    if (posterId != null && requesterId != null) {
      final chatRepo = ChatRepository(firestore: _firestore);
      await chatRepo.createConversation(
        rideId: rideId,
        posterId: posterId!,
        requesterId: requesterId!,
        posterName: posterName,
        posterUniversity: posterUniversity,
        requesterName: requesterName ?? '',
        requesterUniversity: requesterUniversity ?? '',
        rideOrigin: rideOrigin,
        rideDestination: rideDestination,
        rideTransportType: rideTransportType,
        rideDepartureTime: rideDepartureTime,
      );
    }
  }

  /// Declines a join request.
  Future<void> declineRequest(String requestId) async {
    await _requestsCollection.doc(requestId).update({
      'status': 'declined',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Checks if a request from [requesterId] for [rideId] already exists.
  Future<JoinRequest?> existingRequest(
    String rideId,
    String requesterId,
  ) async {
    final snapshot = await _requestsCollection
        .where('rideId', isEqualTo: rideId)
        .where('requesterId', isEqualTo: requesterId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return _requestFromDoc(snapshot.docs.first);
  }

  JoinRequest _requestFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    data['id'] = doc.id;

    // Convert Timestamps to DateTime for Freezed.
    if (data['createdAt'] is Timestamp) {
      data['createdAt'] =
          (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['updatedAt'] is Timestamp) {
      data['updatedAt'] =
          (data['updatedAt'] as Timestamp).toDate().toIso8601String();
    }

    return JoinRequest.fromJson(data);
  }
}
