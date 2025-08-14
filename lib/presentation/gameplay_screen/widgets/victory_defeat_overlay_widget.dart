import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VictoryDefeatOverlayWidget extends StatefulWidget {
  final bool isVictory;
  final int finalScore;
  final double destructionPercentage;
  final int starsEarned;
  final VoidCallback onNextLevel;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;
  final VoidCallback onShare;
  final bool isVisible;

  const VictoryDefeatOverlayWidget({
    super.key,
    required this.isVictory,
    required this.finalScore,
    required this.destructionPercentage,
    required this.starsEarned,
    required this.onNextLevel,
    required this.onRestart,
    required this.onMainMenu,
    required this.onShare,
    required this.isVisible,
  });

  @override
  State<VictoryDefeatOverlayWidget> createState() =>
      _VictoryDefeatOverlayWidgetState();
}

class _VictoryDefeatOverlayWidgetState extends State<VictoryDefeatOverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _overlayController;
  late AnimationController _celebrationController;
  late AnimationController _starsController;
  late Animation<double> _overlayAnimation;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _starsAnimation;

  @override
  void initState() {
    super.initState();

    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _starsController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _overlayAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeInOut,
    ));

    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    _starsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _starsController,
      curve: Curves.bounceOut,
    ));
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _celebrationController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VictoryDefeatOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible && !oldWidget.isVisible) {
      _overlayController.forward();
      _celebrationController.forward();
      if (widget.isVictory) {
        _starsController.forward();
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _overlayController.reverse();
      _celebrationController.reset();
      _starsController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _overlayAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _overlayAnimation.value,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: widget.isVictory
                    ? [
                        AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.8),
                        AppTheme.lightTheme.colorScheme.secondary
                            .withValues(alpha: 0.9),
                      ]
                    : [
                        AppTheme.lightTheme.colorScheme.error
                            .withValues(alpha: 0.7),
                        Colors.black.withValues(alpha: 0.8),
                      ],
              ),
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _celebrationAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _celebrationAnimation.value,
                    child: Container(
                      width: 85.w,
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          SizedBox(height: 4.h),
                          _buildScoreSection(),
                          if (widget.isVictory) ...[
                            SizedBox(height: 3.h),
                            _buildStarsSection(),
                          ],
                          SizedBox(height: 4.h),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        CustomIconWidget(
          iconName:
              widget.isVictory ? 'emoji_events' : 'sentiment_dissatisfied',
          color: widget.isVictory
              ? AppTheme.lightTheme.colorScheme.tertiary
              : AppTheme.lightTheme.colorScheme.error,
          size: 20.w,
        ),
        SizedBox(height: 2.h),
        Text(
          widget.isVictory ? 'Victory!' : 'Level Failed',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: widget.isVictory
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.error,
              ),
        ),
        SizedBox(height: 1.h),
        Text(
          widget.isVictory
              ? 'Excellent destruction work!'
              : 'Don\'t give up, try again!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
        ),
      ],
    );
  }

  Widget _buildScoreSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildScoreItem(
                  'Final Score', widget.finalScore.toString(), 'star'),
              _buildScoreItem(
                  'Destruction',
                  '${widget.destructionPercentage.toStringAsFixed(0)}%',
                  'whatshot'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, String value, String icon) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 6.w,
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
        ),
      ],
    );
  }

  Widget _buildStarsSection() {
    return AnimatedBuilder(
      animation: _starsAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isEarned = index < widget.starsEarned;
            final delay = index * 0.3;
            final starScale = _starsAnimation.value > delay
                ? ((_starsAnimation.value - delay) / (1.0 - delay))
                    .clamp(0.0, 1.0)
                : 0.0;

            return Transform.scale(
              scale: starScale,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: CustomIconWidget(
                  iconName: isEarned ? 'star' : 'star_border',
                  color: isEarned
                      ? AppTheme.lightTheme.colorScheme.tertiary
                      : AppTheme.lightTheme.colorScheme.outline,
                  size: 12.w,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (widget.isVictory) ...[
          _buildActionButton(
            icon: 'arrow_forward',
            label: 'Next Level',
            color: AppTheme.lightTheme.colorScheme.primary,
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onNextLevel();
            },
          ),
          SizedBox(height: 2.h),
        ],
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: 'refresh',
                label: 'Retry',
                color: AppTheme.lightTheme.colorScheme.secondary,
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onRestart();
                },
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildActionButton(
                icon: 'share',
                label: 'Share',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onShare();
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        _buildActionButton(
          icon: 'home',
          label: 'Main Menu',
          color: AppTheme.lightTheme.colorScheme.outline,
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onMainMenu();
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 3.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: color,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
