import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class GameHudWidget extends StatefulWidget {
  final int currentScore;
  final int remainingShots;
  final double destructionPercentage;
  final VoidCallback onPause;
  final bool isPaused;

  const GameHudWidget({
    super.key,
    required this.currentScore,
    required this.remainingShots,
    required this.destructionPercentage,
    required this.onPause,
    required this.isPaused,
  });

  @override
  State<GameHudWidget> createState() => _GameHudWidgetState();
}

class _GameHudWidgetState extends State<GameHudWidget>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late AnimationController _destructionController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _destructionAnimation;

  int _previousScore = 0;
  double _previousDestruction = 0.0;

  @override
  void initState() {
    super.initState();

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _destructionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _scoreController,
      curve: Curves.elasticOut,
    ));

    _destructionAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _destructionController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _destructionController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GameHudWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.currentScore != oldWidget.currentScore) {
      _previousScore = oldWidget.currentScore;
      _scoreController.forward(from: 0);
      HapticFeedback.lightImpact();
    }

    if (widget.destructionPercentage != oldWidget.destructionPercentage) {
      _previousDestruction = oldWidget.destructionPercentage;
      _destructionController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            _buildTopHUD(),
            const Spacer(),
            _buildBottomHUD(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHUD() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildScoreDisplay(),
        _buildPauseButton(),
      ],
    );
  }

  Widget _buildScoreDisplay() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'star',
            color: AppTheme.lightTheme.colorScheme.tertiary,
            size: 6.w,
          ),
          SizedBox(width: 2.w),
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              final displayScore = (_previousScore +
                      (widget.currentScore - _previousScore) *
                          _scoreAnimation.value)
                  .round();

              return Transform.scale(
                scale: 1.0 + _scoreAnimation.value * 0.2,
                child: Text(
                  displayScore.toString(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPauseButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onPause();
      },
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: widget.isPaused ? 'play_arrow' : 'pause',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 6.w,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomHUD() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildShotsRemaining(),
        _buildDestructionMeter(),
      ],
    );
  }

  Widget _buildShotsRemaining() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'sports_baseball',
            color: AppTheme.lightTheme.colorScheme.secondary,
            size: 5.w,
          ),
          SizedBox(width: 2.w),
          Text(
            '${widget.remainingShots}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.secondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestructionMeter() {
    return Container(
      width: 40.w,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Destruction',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
              ),
              AnimatedBuilder(
                animation: _destructionAnimation,
                builder: (context, child) {
                  final displayPercentage = (_previousDestruction +
                      (widget.destructionPercentage - _previousDestruction) *
                          _destructionAnimation.value);

                  return Text(
                    '${displayPercentage.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 1.h),
          AnimatedBuilder(
            animation: _destructionAnimation,
            builder: (context, child) {
              final displayPercentage = (_previousDestruction +
                      (widget.destructionPercentage - _previousDestruction) *
                          _destructionAnimation.value) /
                  100;

              return Container(
                height: 1.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: displayPercentage.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.lightTheme.colorScheme.secondary,
                          AppTheme.lightTheme.colorScheme.primary,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
