import 'package:flutter/material.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/app_spacing.dart';

/// Displays a co-rider's fare balance in a single row.
///
/// Positive balance (they owe you) is shown in green, negative (you owe)
/// in red, and zero shows "Settled" in gray.
class BalanceRow extends StatelessWidget {
  const BalanceRow({
    required this.name,
    required this.university,
    required this.balance,
    super.key,
    this.photoUrl,
  });

  /// Co-rider's display name.
  final String name;

  /// Co-rider's university name.
  final String university;

  /// URL for the co-rider's profile photo (nullable).
  final String? photoUrl;

  /// Net balance in BDT. Positive = they owe you, negative = you owe them.
  final int balance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final universityColor = AppColors.getUniversityColor(university);

    // Determine balance display.
    final String balanceText;
    final Color balanceColor;
    final TextStyle? balanceStyle;

    if (balance > 0) {
      balanceText = '+$balance BDT';
      balanceColor = AppColors.success;
      balanceStyle = theme.textTheme.labelLarge?.copyWith(
        color: balanceColor,
      );
    } else if (balance < 0) {
      balanceText = '-${balance.abs()} BDT';
      balanceColor = AppColors.destructive;
      balanceStyle = theme.textTheme.labelLarge?.copyWith(
        color: balanceColor,
      );
    } else {
      balanceText = 'Settled';
      balanceColor = Theme.of(context).colorScheme.onSurfaceVariant;
      balanceStyle = theme.textTheme.bodySmall?.copyWith(
        color: balanceColor,
      );
    }

    // Accessibility label.
    final String semanticLabel;
    if (balance > 0) {
      semanticLabel = '$name owes you $balance BDT';
    } else if (balance < 0) {
      semanticLabel = 'You owe $name ${balance.abs()} BDT';
    } else {
      semanticLabel = 'Settled with $name';
    }

    return Semantics(
      label: semanticLabel,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
          ),
          child: Row(
            children: [
              // Avatar with university-colored border.
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: universityColor, width: 2),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl!) : null,
                  child: photoUrl == null
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: theme.textTheme.labelLarge,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Name + university.
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      university,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Balance amount.
              Text(balanceText, style: balanceStyle),
            ],
          ),
        ),
      ),
    );
  }
}
