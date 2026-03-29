import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tagme/core/constants/app_spacing.dart';
import 'package:tagme/features/chat/presentation/widgets/conversation_tile.dart';
import 'package:tagme/features/chat/providers/chat_providers.dart';
import 'package:tagme/features/profile/providers/profile_provider.dart';

/// Chat list screen showing all conversations for the current user.
///
/// Displays shimmer loading, empty state, or conversation list with
/// unread badges. Pull-to-refresh triggers Firestore re-listen.
class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _shimmerAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      _shimmerController,
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currentUserId = ref.watch(profileProvider).value?.id ?? '';
    final conversationsAsync = currentUserId.isNotEmpty
        ? ref.watch(conversationListProvider(currentUserId))
        : null;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('Chats', style: theme.textTheme.titleLarge),
        automaticallyImplyLeading: false,
      ),
      body: conversationsAsync == null
          ? _buildEmpty(theme)
          : conversationsAsync.when(
              loading: () => _buildShimmer(),
              error: (_, __) => Center(
                child: Text(
                  'Could not load chats. Pull down to retry.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (conversations) {
                if (conversations.isEmpty) {
                  return _buildEmpty(theme);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(conversationListProvider(currentUserId));
                    await Future<void>.delayed(
                      const Duration(milliseconds: 500),
                    );
                  },
                  child: ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      // Derive other participant info
                      final otherId = conversation.participantIds.firstWhere(
                        (id) => id != currentUserId,
                        orElse: () => '',
                      );
                      final otherName =
                          conversation.participantNames[otherId] ?? 'Unknown';
                      final otherUniversity =
                          conversation.participantUniversities[otherId] ?? '';

                      return ConversationTile(
                        conversation: conversation,
                        currentUserId: currentUserId,
                        otherName: otherName,
                        otherUniversity: otherUniversity,
                        onTap: () =>
                            context.push('/chats/${conversation.id}'),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Chats Yet',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'When you join a ride, you can chat with your co-riders here.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: FadeTransition(
        opacity: _shimmerAnimation,
        child: Column(
          children: List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  // Avatar shimmer
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: cs.surfaceContainerHighest,
                  ),
                  const SizedBox(width: 12),
                  // Text shimmer
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 14,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 12,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
