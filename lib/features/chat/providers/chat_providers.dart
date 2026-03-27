import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tagme/features/chat/data/models/conversation.dart';
import 'package:tagme/features/chat/data/models/message.dart';
import 'package:tagme/features/chat/data/repositories/chat_repository.dart';

part 'chat_providers.g.dart';

/// Streams all conversations for a student, ordered by most recent message.
@riverpod
Stream<List<Conversation>> conversationList(Ref ref, String studentId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.conversationsForStudent(studentId);
}

/// Streams messages for a single conversation (newest first, paginated).
@riverpod
Stream<List<Message>> chatMessages(
  Ref ref,
  String conversationId, {
  int limit = 30,
}) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.messagesForConversation(conversationId, limit: limit);
}

/// Computes total unread message count across all conversations for a student.
@riverpod
int totalUnreadCount(Ref ref, String studentId) {
  final conversationsAsync = ref.watch(conversationListProvider(studentId));
  return conversationsAsync.when(
    data: (conversations) {
      var total = 0;
      for (final conv in conversations) {
        total += conv.unreadCounts[studentId] ?? 0;
      }
      return total;
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// Fetches a single conversation by ID.
@riverpod
Future<Conversation?> conversationDetail(Ref ref, String conversationId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getConversation(conversationId);
}
