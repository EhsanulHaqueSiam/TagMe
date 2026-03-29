import 'package:flutter/material.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/features/chat/data/models/message.dart';
import 'package:url_launcher/url_launcher.dart';

/// Special message card for phone_shared message type.
///
/// Displays a blue-50 card with phone icon, "Phone number shared" label,
/// and the tappable phone number that launches the dialer.
class PhoneShareCard extends StatelessWidget {
  const PhoneShareCard({
    super.key,
    required this.message,
    required this.isSent,
  });

  final Message message;
  final bool isSent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardWidth = MediaQuery.of(context).size.width * 0.8;

    return Semantics(
      label: 'Phone number shared by ${message.senderName}: '
          '${message.phoneNumber ?? ''}. Tap to call.',
      child: Center(
        child: SizedBox(
          width: cardWidth,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender name if received
                if (!isSent)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.senderName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                // Icon + label row
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      size: 20,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Phone number shared',
                      style: theme.textTheme.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Tappable phone number
                if (message.phoneNumber != null)
                  GestureDetector(
                    onTap: () => _launchDialer(message.phoneNumber!),
                    child: Text(
                      message.phoneNumber!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchDialer(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
