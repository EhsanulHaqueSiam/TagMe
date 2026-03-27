import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tagme/features/chat/data/models/conversation.dart';
import 'package:tagme/features/chat/data/models/message.dart';

part 'chat_repository.g.dart';

/// Repository handling Firestore CRUD for chat conversations and messages.
///
/// Uses a top-level `conversations` collection with a `messages` subcollection
/// per conversation for real-time streaming.
@riverpod
ChatRepository chatRepository(Ref ref) {
  return ChatRepository(firestore: FirebaseFirestore.instance);
}

class ChatRepository {
  ChatRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _conversationsCollection =>
      _firestore.collection('conversations');

  /// Creates a conversation between poster and requester for a ride.
  ///
  /// Checks for existing conversation with the same rideId + both participants
  /// to avoid duplicates. Returns the conversation document ID.
  Future<String> createConversation({
    required String rideId,
    required String posterId,
    required String requesterId,
    required String rideOrigin,
    required String rideDestination,
    required String rideTransportType,
    required DateTime rideDepartureTime,
  }) async {
    // Check if conversation already exists for this ride + participants.
    final existing = await _conversationsCollection
        .where('rideId', isEqualTo: rideId)
        .where('participantIds', arrayContains: posterId)
        .get();

    for (final doc in existing.docs) {
      final ids = List<String>.from(doc.data()['participantIds'] as List);
      if (ids.contains(requesterId)) {
        return doc.id; // Already exists
      }
    }

    // Create new conversation document.
    final docRef = await _conversationsCollection.add({
      'participantIds': [posterId, requesterId],
      'rideId': rideId,
      'rideOrigin': rideOrigin,
      'rideDestination': rideDestination,
      'rideTransportType': rideTransportType,
      'rideDepartureTime': Timestamp.fromDate(rideDepartureTime),
      'lastMessage': 'Ride match! Start chatting.',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastSenderId': '',
      'unreadCounts': {posterId: 0, requesterId: 0},
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Add initial system message.
    await docRef.collection('messages').add({
      'senderId': '',
      'senderName': 'System',
      'text': 'You matched on this ride. Say hi!',
      'type': 'system',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Streams all conversations for a student, ordered by most recent message.
  Stream<List<Conversation>> conversationsForStudent(String studentId) {
    return _conversationsCollection
        .where('participantIds', arrayContains: studentId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(_conversationFromDoc).toList(),
        );
  }

  /// Streams messages for a conversation (newest first, paginated).
  Stream<List<Message>> messagesForConversation(
    String conversationId, {
    int limit = 30,
  }) {
    return _conversationsCollection
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(_messageFromDoc).toList(),
        );
  }

  /// Sends a message and updates conversation metadata atomically.
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
    String type = 'text',
    String? phoneNumber,
  }) async {
    final batch = _firestore.batch();

    // Add message document to subcollection.
    final msgRef = _conversationsCollection
        .doc(conversationId)
        .collection('messages')
        .doc();
    batch
      ..set(msgRef, {
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'type': type,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      })
      // Update conversation metadata.
      ..update(_conversationsCollection.doc(conversationId), {
        'lastMessage': type == 'phone_shared' ? 'Shared phone number' : text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderId': senderId,
      });

    await batch.commit();
  }

  /// Resets unread count for a student when they open a conversation.
  Future<void> markAsRead(String conversationId, String studentId) async {
    await _conversationsCollection.doc(conversationId).update({
      'unreadCounts.$studentId': 0,
    });
  }

  /// Fetches a single conversation by ID. Returns null if not found.
  Future<Conversation?> getConversation(String conversationId) async {
    final doc = await _conversationsCollection.doc(conversationId).get();
    if (!doc.exists) return null;
    return _conversationFromDoc(doc);
  }

  /// Converts a Firestore document snapshot to a [Conversation].
  Conversation _conversationFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = Map<String, dynamic>.from(doc.data()!);
    data['id'] = doc.id;

    // Convert Timestamps to ISO 8601 strings for Freezed.
    if (data['lastMessageAt'] is Timestamp) {
      data['lastMessageAt'] =
          (data['lastMessageAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['rideDepartureTime'] is Timestamp) {
      data['rideDepartureTime'] =
          (data['rideDepartureTime'] as Timestamp).toDate().toIso8601String();
    }
    if (data['createdAt'] is Timestamp) {
      data['createdAt'] =
          (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }

    // Ensure unreadCounts map has int values.
    if (data['unreadCounts'] is Map) {
      data['unreadCounts'] = Map<String, int>.from(
        (data['unreadCounts'] as Map).map(
          (key, value) => MapEntry(key.toString(), (value as num).toInt()),
        ),
      );
    }

    // Ensure participantNames and participantUniversities are String maps.
    if (data['participantNames'] is Map) {
      data['participantNames'] = Map<String, String>.from(
        (data['participantNames'] as Map).map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        ),
      );
    }
    if (data['participantUniversities'] is Map) {
      data['participantUniversities'] = Map<String, String>.from(
        (data['participantUniversities'] as Map).map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        ),
      );
    }

    return Conversation.fromJson(data);
  }

  /// Converts a Firestore document snapshot to a [Message].
  Message _messageFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data()!);
    data['id'] = doc.id;

    // Convert Timestamp to ISO 8601 string for Freezed.
    if (data['createdAt'] is Timestamp) {
      data['createdAt'] =
          (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }

    return Message.fromJson(data);
  }
}
