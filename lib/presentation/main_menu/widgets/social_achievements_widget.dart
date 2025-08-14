import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialAchievementsWidget extends StatelessWidget {
  const SocialAchievementsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> achievements = [
      {
        "id": 1,
        "title": "Physics Master",
        "description": "Completed all levels with 3 stars",
        "icon": "emoji_events",
        "progress": 85,
        "isUnlocked": false,
        "color": AppTheme.lightTheme.colorScheme.tertiary,
      },
      {
        "id": 2,
        "title": "Destruction King",
        "description": "Destroyed 1000 objects",
        "icon": "whatshot",
        "progress": 100,
        "isUnlocked": true,
        "color": AppTheme.lightTheme.colorScheme.primary,
      },
      {
        "id": 3,
        "title": "Selfie Shooter",
        "description": "Used 50 different selfies",
        "icon": "camera_alt",
        "progress": 60,
        "isUnlocked": false,
        "color": AppTheme.lightTheme.colorScheme.secondary,
      },
      {
        "id": 4,
        "title": "Social Star",
        "description": "Shared 10 gameplay videos",
        "icon": "share",
        "progress": 30,
        "isUnlocked": false,
        "color": AppTheme.lightTheme.colorScheme.error,
      },
    ];

    final List<Map<String, dynamic>> recentScores = [
      {
        "level": "Kitchen Chaos",
        "score": 2850,
        "stars": 3,
        "timestamp": "2 hours ago",
      },
      {
        "level": "Toy Tower",
        "score": 1920,
        "stars": 2,
        "timestamp": "1 day ago",
      },
      {
        "level": "Building Blast",
        "score": 3200,
        "stars": 3,
        "timestamp": "2 days ago",
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Achievements Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Navigate to full achievements screen
                },
                child: Text(
                  'View All',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 12.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: achievements.length,
              separatorBuilder: (context, index) => SizedBox(width: 3.w),
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                final isUnlocked = achievement["isUnlocked"] as bool;
                final progress = achievement["progress"] as int;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showAchievementDetails(context, achievement);
                  },
                  child: Container(
                    width: 25.w,
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isUnlocked
                            ? (achievement["color"] as Color)
                            : AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.lightTheme.colorScheme.shadow
                              .withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress / 100,
                              strokeWidth: 3,
                              backgroundColor: AppTheme
                                  .lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                achievement["color"] as Color,
                              ),
                            ),
                            CustomIconWidget(
                              iconName: achievement["icon"] as String,
                              color: isUnlocked
                                  ? (achievement["color"] as Color)
                                  : AppTheme.lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                              size: 20,
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          achievement["title"] as String,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: isUnlocked
                                    ? AppTheme.lightTheme.colorScheme.onSurface
                                    : AppTheme.lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 3.h),

          // Recent High Scores Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent High Scores',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Navigate to leaderboard
                },
                child: Text(
                  'Leaderboard',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 10.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recentScores.length,
              separatorBuilder: (context, index) => SizedBox(width: 3.w),
              itemBuilder: (context, index) {
                final score = recentScores[index];
                final stars = score["stars"] as int;

                return Container(
                  width: 45.w,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              score["level"] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: List.generate(3, (starIndex) {
                              return CustomIconWidget(
                                iconName: 'star',
                                color: starIndex < stars
                                    ? AppTheme.lightTheme.colorScheme.tertiary
                                    : AppTheme.lightTheme.colorScheme.outline
                                        .withValues(alpha: 0.3),
                                size: 12,
                              );
                            }),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${score["score"]}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
                          ),
                          Text(
                            score["timestamp"] as String,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAchievementDetails(
      BuildContext context, Map<String, dynamic> achievement) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            CustomIconWidget(
              iconName: achievement["icon"] as String,
              color: achievement["color"] as Color,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              achievement["title"] as String,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
            ),
            SizedBox(height: 1.h),
            Text(
              achievement["description"] as String,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            LinearProgressIndicator(
              value: (achievement["progress"] as int) / 100,
              backgroundColor: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
              valueColor:
                  AlwaysStoppedAnimation<Color>(achievement["color"] as Color),
            ),
            SizedBox(height: 1.h),
            Text(
              '${achievement["progress"]}% Complete',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }
}
