import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class PlayerHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> playerData;

  const PlayerHeaderWidget({
    super.key,
    required this.playerData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playerName = playerData['name'] as String? ?? 'Player';
    final totalStars = playerData['totalStars'] as int? ?? 0;
    final avatarUrl = playerData['avatarUrl'] as String?;
    final completedLevels = playerData['completedLevels'] as int? ?? 0;
    final totalLevels = playerData['totalLevels'] as int? ?? 10;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Player avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: avatarUrl != null
                    ? CustomImageWidget(
                        imageUrl: avatarUrl,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        child: CustomIconWidget(
                          iconName: 'person',
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                      ),
              ),
            ),

            const SizedBox(width: 16),

            // Player info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playerName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completedLevels/$totalLevels levels completed',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Stars collected
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.accentLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.accentLight.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'star',
                    color: AppTheme.accentLight,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$totalStars',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppTheme.accentLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
