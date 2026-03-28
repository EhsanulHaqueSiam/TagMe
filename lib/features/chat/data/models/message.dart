import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

/// A single message within a chat conversation.
@freezed
abstract class Message with _$Message {
  const factory Message({
    required String senderId,
    required String senderName,
    required String text,
    @Default('text') String type, // 'text', 'phone_shared', 'system', 'location_shared'
    String? id,
    String? phoneNumber, // Only for phone_shared type
    double? latitude, // Only for location_shared type
    double? longitude, // Only for location_shared type
    String? locationLabel, // Only for location_shared type
    DateTime? createdAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
