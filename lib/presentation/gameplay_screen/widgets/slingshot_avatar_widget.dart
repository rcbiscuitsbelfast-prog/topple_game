import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SlingshotAvatarWidget extends StatefulWidget {
  final String? selfieImagePath;
  final bool isLaunching;
  final double power;
  final double angle;
  final VoidCallback? onTap;
  final Offset position;
  final bool isDragging;
  final double slingshotStretch;

  const SlingshotAvatarWidget({
    super.key,
    this.selfieImagePath,
    required this.isLaunching,
    required this.power,
    required this.angle,
    this.onTap,
    required this.position,
    required this.isDragging,
    required this.slingshotStretch,
  });

  @override
  State<SlingshotAvatarWidget> createState() => _SlingshotAvatarWidgetState();
}

class _SlingshotAvatarWidgetState extends State<SlingshotAvatarWidget>
    with TickerProviderStateMixin {
  late AnimationController _launchController;
  late AnimationController _idleController;
  late AnimationController _chargeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _chargeAnimation;

  @override
  void initState() {
    super.initState();

    _launchController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _idleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _chargeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _launchController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: math.pi * 3,
    ).animate(CurvedAnimation(
      parent: _launchController,
      curve: Curves.easeInOut,
    ));

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -100),
    ).animate(CurvedAnimation(
      parent: _launchController,
      curve: Curves.easeOutCubic,
    ));

    _chargeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chargeController,
      curve: Curves.elasticOut,
    ));

    // Start idle animation
    _idleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _launchController.dispose();
    _idleController.dispose();
    _chargeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SlingshotAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLaunching && !oldWidget.isLaunching) {
      _launchController.forward(from: 0);
      HapticFeedback.mediumImpact();
    } else if (!widget.isLaunching && oldWidget.isLaunching) {
      _launchController.reverse();
    }

    if (widget.isDragging && !oldWidget.isDragging) {
      _chargeController.repeat();
    } else if (!widget.isDragging && oldWidget.isDragging) {
      _chargeController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 10.w,
      top: widget.position.dy - 10.w,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge(
              [_launchController, _idleController, _chargeController]),
          builder: (context, child) {
            // Calculate stretch effect based on power
            final stretchScale = 1.0 + (widget.power * 0.3);
            final idleOffset =
                Offset(0, math.sin(_idleController.value * math.pi) * 2);
            final chargeEffect = widget.isDragging
                ? math.sin(_chargeController.value * math.pi * 8) * 2
                : 0.0;

            return Transform.translate(
              offset: _positionAnimation.value +
                  idleOffset +
                  Offset(chargeEffect, 0),
              child: Transform.scale(
                scale: _scaleAnimation.value * stretchScale,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Power charge effect
                      if (widget.isDragging && widget.power > 0.1)
                        _buildPowerChargeEffect(),

                      // Main avatar container
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getPowerColor(),
                            width: 3 + widget.power * 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getPowerColor().withValues(alpha: 0.4),
                              blurRadius: 15 + widget.power * 10,
                              spreadRadius: 2 + widget.power * 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _buildAvatarContent(),
                        ),
                      ),

                      // Angry expression overlay when charging
                      if (widget.isDragging && widget.power > 0.3)
                        _buildAngryOverlay(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPowerChargeEffect() {
    return AnimatedBuilder(
      animation: _chargeController,
      builder: (context, child) {
        return Container(
          width:
              (20.w + widget.power * 50) * (1 + _chargeAnimation.value * 0.2),
          height:
              (20.w + widget.power * 50) * (1 + _chargeAnimation.value * 0.2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _getPowerColor().withValues(alpha: 0.0),
                _getPowerColor().withValues(alpha: 0.1 + widget.power * 0.2),
                _getPowerColor().withValues(alpha: 0.3 + widget.power * 0.3),
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
        );
      },
    );
  }

  Color _getPowerColor() {
    if (widget.power < 0.3) {
      return AppTheme.lightTheme.colorScheme.primary;
    } else if (widget.power < 0.7) {
      return Color.lerp(
        AppTheme.lightTheme.colorScheme.primary,
        AppTheme.lightTheme.colorScheme.tertiary,
        (widget.power - 0.3) / 0.4,
      )!;
    } else {
      return Color.lerp(
        AppTheme.lightTheme.colorScheme.tertiary,
        Colors.red,
        (widget.power - 0.7) / 0.3,
      )!;
    }
  }

  Widget _buildAngryOverlay() {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: CustomPaint(
        painter: AngryFacePainter(
          power: widget.power,
          animation: _chargeAnimation.value,
        ),
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (widget.selfieImagePath != null) {
      if (widget.selfieImagePath!.startsWith('assets/')) {
        // Local asset image
        return Image.asset(
          widget.selfieImagePath!,
          width: 20.w,
          height: 20.w,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar();
          },
        );
      } else {
        // Network image
        return CustomImageWidget(
          imageUrl: widget.selfieImagePath!,
          width: 20.w,
          height: 20.w,
          fit: BoxFit.cover,
        );
      }
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.secondary,
          ],
        ),
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: 'person',
          color: Colors.white,
          size: 10.w,
        ),
      ),
    );
  }
}

class AngryFacePainter extends CustomPainter {
  final double power;
  final double animation;

  AngryFacePainter({
    required this.power,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw angry effects only if power is high
    if (power > 0.5) {
      final intensity = (power - 0.5) / 0.5;

      // Angry glow
      final glowPaint = Paint()
        ..color = Colors.red.withValues(alpha: intensity * 0.3 * animation)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(center, radius, glowPaint);

      // Steam lines
      if (intensity > 0.7) {
        final steamPaint = Paint()
          ..color = Colors.white.withValues(alpha: intensity * 0.6)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

        for (int i = 0; i < 3; i++) {
          final xOffset = (i - 1) * 8.0;
          final steamY = math.sin(animation * math.pi * 4 + i) * 5;

          canvas.drawLine(
            Offset(center.dx + xOffset, center.dy - radius * 0.8),
            Offset(center.dx + xOffset, center.dy - radius * 0.8 - 15 + steamY),
            steamPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
