import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

/// A chat conversation between two ride-sharing partners.
@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    required List<String> participantIds,
    required String rideId,
    required String rideOrigin,
    required String rideDestination,
    required String rideTransportType,
    String? id,
    String? lastMessage,
    String? lastSenderId,
    @Default({}) Map<String, int> unreadCounts,
    DateTime? lastMessageAt,
    DateTime? rideDepartureTime,
    DateTime? createdAt,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}
