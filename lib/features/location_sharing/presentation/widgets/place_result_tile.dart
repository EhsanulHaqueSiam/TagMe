import 'package:flutter/material.dart';

/// A single autocomplete result row for the place search screen.
///
/// Shows a location icon, primary label, and optional secondary label.
/// Height: 60px, horizontal padding: 16px. Dividers are handled by
/// the parent ListView's separator builder.
class PlaceResultTile extends StatelessWidget {
  const PlaceResultTile({
    super.key,
    required this.label,
    this.secondaryLabel,
    required this.onTap,
  });

  final String label;
  final String? secondaryLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (secondaryLabel != null)
                      Text(
                        secondaryLabel!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
