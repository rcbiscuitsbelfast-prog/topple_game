import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';

class LevelCardWidget extends StatelessWidget {
  final Map<String, dynamic> levelData;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const LevelCardWidget({
    super.key,
    required this.levelData,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocked = levelData['isLocked'] as bool? ?? false;
    final isCompleted = levelData['isCompleted'] as bool? ?? false;
    final starRating = levelData['starRating'] as int? ?? 0;
    final levelNumber = levelData['levelNumber'] as int? ?? 1;
    final theme_name = levelData['theme'] as String? ?? 'dishes';
    final bestScore = levelData['bestScore'] as int? ?? 0;
    final difficulty = levelData['difficulty'] as String? ?? 'Easy';

    return GestureDetector(
      onTap: isLocked
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap();
            },
      onLongPress: isLocked
          ? null
          : () {
              HapticFeedback.mediumImpact();
              onLongPress?.call();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isLocked
              ? theme.colorScheme.surface.withValues(alpha: 0.5)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? AppTheme.successLight
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomImageWidget(
                imageUrl: _getThemeImageUrl(theme_name),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // Overlay gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            // Lock overlay
            if (isLocked)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withValues(alpha: 0.6),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'lock',
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Level number and difficulty
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$levelNumber',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!isLocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(difficulty)
                                .withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            difficulty,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const Spacer(),

                  // Theme name
                  if (!isLocked)
                    Text(
                      theme_name.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),

                  const SizedBox(height: 4),

                  // Star rating and best score
                  if (!isLocked)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Star rating
                        Row(
                          children: List.generate(3, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: CustomIconWidget(
                                iconName:
                                    index < starRating ? 'star' : 'star_border',
                                color: index < starRating
                                    ? AppTheme.accentLight
                                    : Colors.white.withValues(alpha: 0.5),
                                size: 16,
                              ),
                            );
                          }),
                        ),

                        // Best score
                        if (bestScore > 0)
                          Text(
                            '$bestScore',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),

            // Completion badge
            if (isCompleted && !isLocked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.successLight,
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'check',
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getThemeImageUrl(String theme) {
    switch (theme.toLowerCase()) {
      case 'dishes':
        return 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?fm=jpg&q=60&w=400&h=300&fit=crop';
      case 'toys':
        return 'https://images.pexels.com/photos/1148998/pexels-photo-1148998.jpeg?auto=compress&cs=tinysrgb&w=400&h=300&fit=crop';
      case 'furniture':
        return 'https://images.pixabay.com/photo/2016/11/19/13/06/chair-1839818_960_720.jpg?w=400&h=300&fit=crop';
      case 'buildings':
        return 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?fm=jpg&q=60&w=400&h=300&fit=crop';
      default:
        return 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?fm=jpg&q=60&w=400&h=300&fit=crop';
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppTheme.successLight;
      case 'medium':
        return AppTheme.warningLight;
      case 'hard':
        return AppTheme.errorLight;
      default:
        return AppTheme.successLight;
    }
  }
}
