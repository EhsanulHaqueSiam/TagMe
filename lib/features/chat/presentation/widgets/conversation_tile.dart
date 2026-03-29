import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/app_spacing.dart';
import 'package:tagme/features/chat/data/models/conversation.dart';

/// A single conversation row in the chat list.
///
/// Shows avatar with university-colored border, participant name,
/// last message preview, ride context, timestamp, and unread badge.
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.otherName,
    required this.otherUniversity,
    required this.onTap,
  });

  final Conversation conversation;
  final String currentUserId;
  final String otherName;
  final String otherUniversity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final unreadCount = conversation.unreadCounts[currentUserId] ?? 0;
    final universityColor = AppColors.getUniversityColor(otherUniversity);
    final initial =
        otherName.isNotEmpty ? otherName[0].toUpperCase() : '?';
    final timestampText = _formatTimestamp(conversation.lastMessageAt);

    return Semantics(
      label: '$otherName, $otherUniversity, '
          'last message: ${conversation.lastMessage ?? ''}, '
          '$timestampText, '
          '${unreadCount > 0 ? '$unreadCount unread messages' : 'no unread messages'}',
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(
              bottom: BorderSide(color: cs.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: universityColor, width: 3),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: cs.surfaceContainerHighest,
                  child: Text(
                    initial,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Center text column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + timestamp row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            otherName,
                            style: theme.textTheme.labelLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timestampText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Last message preview
                    Text(
                      conversation.lastMessage ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Ride context
                    Text(
                      '${conversation.rideOrigin} -> ${conversation.rideDestination}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Unread badge
              if (unreadCount > 0) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDay == today) {
      return DateFormat.jm().format(dateTime);
    }
    if (messageDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    return DateFormat('MMM d').format(dateTime);
  }
}
