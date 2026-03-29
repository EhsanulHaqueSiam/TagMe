import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/features/chat/data/models/message.dart';

/// A single chat message bubble with sent/received styling.
///
/// Sent messages: accent background, white text, right-aligned.
/// Received messages: white background with border, dark text, left-aligned.
/// System messages: centered caption text, no bubble.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isSent,
    this.showTimestamp = true,
  });

  final Message message;
  final bool isSent;
  final bool showTimestamp;

  @override
  Widget build(BuildContext context) {
    // System messages
    if (message.type == 'system') {
      return _buildSystemMessage(context);
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final maxWidth = MediaQuery.of(context).size.width * 0.75;
    final timestampText = message.createdAt != null
        ? DateFormat.jm().format(message.createdAt!)
        : '';

    return Semantics(
      label: '${isSent ? 'Sent' : 'Received'} message: ${message.text}, '
          '$timestampText',
      child: Column(
        crossAxisAlignment:
            isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Bubble
          Row(
            mainAxisAlignment:
                isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSent ? AppColors.accent : cs.surface,
                    border: isSent
                        ? null
                        : Border.all(color: cs.outlineVariant),
                    borderRadius: isSent
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(4),
                            bottomLeft: Radius.circular(16),
                          )
                        : const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                            bottomLeft: Radius.circular(4),
                          ),
                  ),
                  child: Text(
                    message.text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isSent ? Colors.white : cs.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Timestamp
          if (showTimestamp && timestampText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                timestampText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          message.text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
