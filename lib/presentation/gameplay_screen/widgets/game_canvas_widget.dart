import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../gameplay_screen.dart';

class GameCanvasWidget extends StatefulWidget {
  final Function(Offset) onDragStart;
  final Function(Offset) onDragUpdate;
  final Function(Offset) onDragEnd;
  final bool isLaunching;
  final double destructionPercentage;
  final List<HouseholdGameObject> gameObjects;
  final Offset? trajectoryStart;
  final Offset? trajectoryEnd;
  final bool showTrajectory;
  final Offset slingshotPosition;
  final ProjectileData? activeProjectile;
  final double launchPower;

  const GameCanvasWidget({
    super.key,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.isLaunching,
    required this.destructionPercentage,
    required this.gameObjects,
    this.trajectoryStart,
    this.trajectoryEnd,
    required this.showTrajectory,
    required this.slingshotPosition,
    this.activeProjectile,
    required this.launchPower,
  });

  @override
  State<GameCanvasWidget> createState() => _GameCanvasWidgetState();
}

class _GameCanvasWidgetState extends State<GameCanvasWidget>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _shakeController;
  late AnimationController _destructionController;
  final List<ParticleData> _particles = [];
  final List<DebrisData> _debris = [];
  Offset? _impactPoint;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _destructionController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _particleController.dispose();
    _shakeController.dispose();
    _destructionController.dispose();
    super.dispose();
  }

  void _createExplosionEffect(Offset position, String material) {
    _particles.clear();
    _debris.clear();
    final random = math.Random();

    // Create material-specific particles
    final particleCount = material == "glass" ? 30 : 20;
    final particleColors = _getParticleColors(material);

    for (int i = 0; i < particleCount; i++) {
      _particles.add(ParticleData(
        position: position,
        velocity: Offset(
          (random.nextDouble() - 0.5) * 300,
          (random.nextDouble() - 0.5) * 200 - 100,
        ),
        color: particleColors[random.nextInt(particleColors.length)],
        size: random.nextDouble() * 6 + 2,
        life: 1.0,
        gravity: material == "glass" ? 200 : 300,
      ));
    }

    // Create larger debris pieces
    for (int i = 0; i < 8; i++) {
      _debris.add(DebrisData(
        position: position,
        velocity: Offset(
          (random.nextDouble() - 0.5) * 150,
          -random.nextDouble() * 100,
        ),
        size: Size(
          random.nextDouble() * 15 + 5,
          random.nextDouble() * 15 + 5,
        ),
        rotation: random.nextDouble() * math.pi * 2,
        angularVelocity: (random.nextDouble() - 0.5) * 10,
        color: _getDebrisColor(material),
        life: 1.0,
      ));
    }

    _impactPoint = position;
    _particleController.forward(from: 0);
    _destructionController.forward(from: 0);
  }

  List<Color> _getParticleColors(String material) {
    switch (material) {
      case "glass":
        return [
          const Color(0xFFB3E5FC),
          const Color(0xFF81D4FA),
          const Color(0xFF4FC3F7),
          Colors.white,
        ];
      case "ceramic":
        return [
          const Color(0xFFFFF9C4),
          const Color(0xFFFFF176),
          const Color(0xFFFFEB3B),
          const Color(0xFFFFD54F),
        ];
      case "metal":
        return [
          const Color(0xFFE0E0E0),
          const Color(0xFFBDBDBD),
          const Color(0xFF9E9E9E),
          const Color(0xFF757575),
        ];
      default:
        return [
          AppTheme.lightTheme.colorScheme.primary,
          AppTheme.lightTheme.colorScheme.secondary,
          AppTheme.lightTheme.colorScheme.tertiary,
        ];
    }
  }

  Color _getDebrisColor(String material) {
    switch (material) {
      case "glass":
        return const Color(0xFFB3E5FC);
      case "ceramic":
        return const Color(0xFFFFF9C4);
      case "metal":
        return const Color(0xFFBDBDBD);
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  void _triggerImpact(Offset position) {
    setState(() {
      _impactPoint = position;
    });
    _createExplosionEffect(position, "ceramic");
    _shakeController.forward(from: 0);
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: GestureDetector(
        onPanStart: (details) {
          widget.onDragStart(details.localPosition);
          HapticFeedback.lightImpact();
        },
        onPanUpdate: (details) {
          widget.onDragUpdate(details.localPosition);
        },
        onPanEnd: (details) {
          widget.onDragEnd(details.localPosition);
        },
        child: AnimatedBuilder(
          animation: Listenable.merge(
              [_particleController, _shakeController, _destructionController]),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                math.sin(_shakeController.value * math.pi * 8) *
                    3 *
                    (1.0 - _shakeController.value),
                0,
              ),
              child: CustomPaint(
                painter: EnhancedGameCanvasPainter(
                  gameObjects: widget.gameObjects,
                  trajectoryStart: widget.trajectoryStart,
                  trajectoryEnd: widget.trajectoryEnd,
                  showTrajectory: widget.showTrajectory,
                  particles: _particles,
                  debris: _debris,
                  particleAnimation: _particleController.value,
                  destructionAnimation: _destructionController.value,
                  impactPoint: _impactPoint,
                  slingshotPosition: widget.slingshotPosition,
                  activeProjectile: widget.activeProjectile,
                  launchPower: widget.launchPower,
                ),
                size: Size.infinite,
              ),
            );
          },
        ),
      ),
    );
  }
}

class EnhancedGameCanvasPainter extends CustomPainter {
  final List<HouseholdGameObject> gameObjects;
  final Offset? trajectoryStart;
  final Offset? trajectoryEnd;
  final bool showTrajectory;
  final List<ParticleData> particles;
  final List<DebrisData> debris;
  final double particleAnimation;
  final double destructionAnimation;
  final Offset? impactPoint;
  final Offset slingshotPosition;
  final ProjectileData? activeProjectile;
  final double launchPower;

  EnhancedGameCanvasPainter({
    required this.gameObjects,
    this.trajectoryStart,
    this.trajectoryEnd,
    required this.showTrajectory,
    required this.particles,
    required this.debris,
    required this.particleAnimation,
    required this.destructionAnimation,
    this.impactPoint,
    required this.slingshotPosition,
    this.activeProjectile,
    required this.launchPower,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw enhanced background
    _drawEnhancedBackground(canvas, size);

    // Draw ground with texture
    _drawRealisticGround(canvas, size);

    // Draw slingshot structure
    _drawSlingshot(canvas);

    // Draw household objects with realistic appearance
    for (final obj in gameObjects) {
      _drawHouseholdObject(canvas, obj);
    }

    // Draw trajectory with physics arc
    if (showTrajectory && trajectoryStart != null && trajectoryEnd != null) {
      _drawPhysicsTrajectory(canvas, trajectoryStart!, trajectoryEnd!);
    }

    // Draw active projectile (face)
    if (activeProjectile != null) {
      _drawProjectile(canvas, activeProjectile!);
    }

    // Draw particles and debris
    if (particleAnimation > 0) {
      _drawParticles(canvas);
      _drawDebris(canvas);
    }

    // Draw impact effects
    if (impactPoint != null && destructionAnimation > 0) {
      _drawEnhancedImpactEffect(canvas, impactPoint!);
    }
  }

  void _drawEnhancedBackground(Canvas canvas, Size size) {
    // Sky gradient with clouds
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF87CEEB),
          const Color(0xFFE0F6FF),
          const Color(0xFFF0F8FF),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Draw animated clouds
    _drawClouds(canvas, size);
  }

  void _drawClouds(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Cloud positions that slowly move
    final clouds = [
      Offset(size.width * 0.2, size.height * 0.15),
      Offset(size.width * 0.6, size.height * 0.1),
      Offset(size.width * 0.8, size.height * 0.2),
    ];

    for (final cloudPos in clouds) {
      _drawCloud(canvas, cloudPos, cloudPaint);
    }
  }

  void _drawCloud(Canvas canvas, Offset position, Paint paint) {
    canvas.drawCircle(position, 20, paint);
    canvas.drawCircle(position + const Offset(15, 5), 15, paint);
    canvas.drawCircle(position + const Offset(30, 0), 18, paint);
    canvas.drawCircle(position + const Offset(20, -10), 12, paint);
  }

  void _drawRealisticGround(Canvas canvas, Size size) {
    final groundRect =
        Rect.fromLTWH(0, size.height * 0.85, size.width, size.height * 0.15);

    // Grass gradient
    final grassPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF8FBC8F),
          const Color(0xFF556B2F),
        ],
      ).createShader(groundRect);

    canvas.drawRect(groundRect, grassPaint);

    // Add grass texture lines
    final grassLinePaint = Paint()
      ..color = const Color(0xFF6B8E23).withValues(alpha: 0.5)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 3) {
      canvas.drawLine(
        Offset(x, size.height * 0.85),
        Offset(x + 1, size.height * 0.87),
        grassLinePaint,
      );
    }
  }

  void _drawSlingshot(Canvas canvas) {
    final slingshotPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    // Left arm
    canvas.drawLine(
      slingshotPosition + const Offset(-20, -40),
      slingshotPosition + const Offset(-15, 10),
      slingshotPaint,
    );

    // Right arm
    canvas.drawLine(
      slingshotPosition + const Offset(20, -40),
      slingshotPosition + const Offset(15, 10),
      slingshotPaint,
    );

    // Base
    canvas.drawLine(
      slingshotPosition + const Offset(-15, 10),
      slingshotPosition + const Offset(15, 10),
      slingshotPaint,
    );

    // Elastic band (if dragging)
    if (showTrajectory && trajectoryEnd != null) {
      final elasticPaint = Paint()
        ..color = const Color(0xFF2E2E2E)
        ..strokeWidth = 3;

      canvas.drawLine(
        slingshotPosition + const Offset(-15, -30),
        trajectoryEnd!,
        elasticPaint,
      );

      canvas.drawLine(
        slingshotPosition + const Offset(15, -30),
        trajectoryEnd!,
        elasticPaint,
      );
    } else {
      // Relaxed elastic
      final elasticPaint = Paint()
        ..color = const Color(0xFF2E2E2E)
        ..strokeWidth = 2;

      canvas.drawLine(
        slingshotPosition + const Offset(-15, -30),
        slingshotPosition + const Offset(15, -30),
        elasticPaint,
      );
    }
  }

  void _drawHouseholdObject(Canvas canvas, HouseholdGameObject obj) {
    canvas.save();
    canvas.translate(obj.position.dx, obj.position.dy);
    canvas.rotate(obj.rotation);

    final paint = Paint()
      ..color = obj.isDestroyed ? obj.color.withValues(alpha: 0.4) : obj.color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = obj.isDestroyed
          ? Colors.grey.withValues(alpha: 0.5)
          : obj.color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    switch (obj.type) {
      case "plate":
        _drawPlate(canvas, obj.size, paint, strokePaint);
        break;
      case "cup":
        _drawCup(canvas, obj.size, paint, strokePaint);
        break;
      case "bowl":
        _drawBowl(canvas, obj.size, paint, strokePaint);
        break;
      case "glass":
        _drawGlass(canvas, obj.size, paint, strokePaint);
        break;
      case "bottle":
        _drawBottle(canvas, obj.size, paint, strokePaint);
        break;
      case "pan":
        _drawPan(canvas, obj.size, paint, strokePaint);
        break;
      case "vase":
        _drawVase(canvas, obj.size, paint, strokePaint);
        break;
      default:
        _drawGenericObject(canvas, obj.size, paint, strokePaint);
    }

    canvas.restore();
  }

  void _drawPlate(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final rect = Rect.fromCenter(
        center: Offset.zero, width: size.width, height: size.height);
    canvas.drawOval(rect, fill);
    canvas.drawOval(rect, stroke);

    // Inner circle for plate rim
    final innerRect = Rect.fromCenter(
        center: Offset.zero,
        width: size.width * 0.7,
        height: size.height * 0.7);
    canvas.drawOval(innerRect, stroke);
  }

  void _drawCup(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset.zero, width: size.width, height: size.height),
      Radius.circular(size.width * 0.1),
    );
    canvas.drawRRect(rect, fill);
    canvas.drawRRect(rect, stroke);

    // Handle
    final handlePath = Path()
      ..moveTo(size.width / 2, -size.height / 4)
      ..quadraticBezierTo(
          size.width / 2 + 15, 0, size.width / 2, size.height / 4);
    canvas.drawPath(handlePath, stroke);
  }

  void _drawBowl(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final rect = Rect.fromCenter(
        center: Offset.zero, width: size.width, height: size.height);
    canvas.drawOval(rect, fill);
    canvas.drawOval(rect, stroke);

    // Inner shadow for depth
    final innerPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    final innerRect = Rect.fromCenter(
        center: const Offset(0, 2),
        width: size.width * 0.8,
        height: size.height * 0.6);
    canvas.drawOval(innerRect, innerPaint);
  }

  void _drawGlass(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final path = Path()
      ..moveTo(-size.width / 2, -size.height / 2)
      ..lineTo(-size.width / 3, size.height / 2)
      ..lineTo(size.width / 3, size.height / 2)
      ..lineTo(size.width / 2, -size.height / 2)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Highlight for glass effect
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(-size.width / 2 + 3, -size.height / 2),
      Offset(-size.width / 3 + 2, size.height / 2),
      highlightPaint,
    );
  }

  void _drawBottle(Canvas canvas, Size size, Paint fill, Paint stroke) {
    // Bottle body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: const Offset(0, 10),
          width: size.width,
          height: size.height * 0.7),
      Radius.circular(size.width * 0.1),
    );
    canvas.drawRRect(bodyRect, fill);
    canvas.drawRRect(bodyRect, stroke);

    // Bottle neck
    final neckRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(0, -size.height / 2 + 5),
          width: size.width * 0.4,
          height: size.height * 0.3),
      Radius.circular(size.width * 0.05),
    );
    canvas.drawRRect(neckRect, fill);
    canvas.drawRRect(neckRect, stroke);
  }

  void _drawPan(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final rect = Rect.fromCenter(
        center: Offset.zero, width: size.width, height: size.height);
    canvas.drawOval(rect, fill);
    canvas.drawOval(rect, stroke);

    // Handle
    final handlePath = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width / 2 + 20, 0);
    canvas.drawPath(
        handlePath,
        Paint()
          ..color = const Color(0xFF8B4513)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round);
  }

  void _drawVase(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final path = Path()
      ..moveTo(-size.width / 4, -size.height / 2)
      ..quadraticBezierTo(-size.width / 2, -size.height / 4, -size.width / 3, 0)
      ..quadraticBezierTo(
          -size.width / 2, size.height / 4, -size.width / 4, size.height / 2)
      ..lineTo(size.width / 4, size.height / 2)
      ..quadraticBezierTo(size.width / 2, size.height / 4, size.width / 3, 0)
      ..quadraticBezierTo(
          size.width / 2, -size.height / 4, size.width / 4, -size.height / 2)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawGenericObject(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final rect = Rect.fromCenter(
        center: Offset.zero, width: size.width, height: size.height);
    canvas.drawRect(rect, fill);
    canvas.drawRect(rect, stroke);
  }

  void _drawPhysicsTrajectory(Canvas canvas, Offset start, Offset end) {
    final paint = Paint()
      ..color = AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw parabolic trajectory path
    final path = Path();
    path.moveTo(start.dx, start.dy);

    final steps = 20;
    for (int i = 1; i <= steps; i++) {
      final t = i / steps;
      final x = start.dx + (end.dx - start.dx) * t;
      final y =
          start.dy + (end.dy - start.dy) * t + 100 * t * t; // Gravity effect

      if (i == 1) {
        path.lineTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw dashed trajectory
    const dashWidth = 8.0;
    const dashSpace = 4.0;
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final nextDistance = math.min(distance + dashWidth, pathMetric.length);
        final segment = pathMetric.extractPath(distance, nextDistance);
        canvas.drawPath(segment, paint);
        distance = nextDistance + dashSpace;
      }
    }

    // Draw power indicator at launch point
    _drawPowerIndicator(canvas, start);
  }

  void _drawPowerIndicator(Canvas canvas, Offset position) {
    final radius = 30.0 * launchPower;
    final paint = Paint()
      ..color = Color.lerp(
        Colors.green,
        Colors.red,
        launchPower,
      )!
          .withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, radius, paint);

    final strokePaint = Paint()
      ..color = Color.lerp(Colors.green, Colors.red, launchPower)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(position, radius, strokePaint);
  }

  void _drawProjectile(Canvas canvas, ProjectileData projectile) {
    canvas.save();
    canvas.translate(projectile.position.dx, projectile.position.dy);
    canvas.rotate(projectile.rotation);

    // Draw face projectile
    final facePaint = Paint()
      ..color = const Color(0xFFFFDBB5)
      ..style = PaintingStyle.fill;

    final faceStroke = Paint()
      ..color = const Color(0xFFD4A574)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Face circle
    canvas.drawCircle(Offset.zero, 15, facePaint);
    canvas.drawCircle(Offset.zero, 15, faceStroke);

    // Eyes
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(-5, -3), 2, eyePaint);
    canvas.drawCircle(const Offset(5, -3), 2, eyePaint);

    // Mouth (angry expression)
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path()
      ..moveTo(-6, 5)
      ..quadraticBezierTo(0, 8, 6, 5);
    canvas.drawPath(mouthPath, mouthPaint);

    canvas.restore();

    // Trail effect
    _drawProjectileTrail(canvas, projectile);
  }

  void _drawProjectileTrail(Canvas canvas, ProjectileData projectile) {
    final trailPaint = Paint()
      ..color = AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Simple trail dots
    for (int i = 1; i <= 3; i++) {
      final trailPos =
          projectile.position - (projectile.velocity.normalized * (i * 10.0));
      final alpha = (1.0 - i * 0.3).clamp(0.0, 1.0);
      canvas.drawCircle(
        trailPos,
        (4 - i).toDouble(),
        Paint()
          ..color = AppTheme.lightTheme.colorScheme.primary
              .withValues(alpha: alpha * 0.5)
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _drawParticles(Canvas canvas) {
    for (final particle in particles) {
      final currentLife = 1.0 - particleAnimation;
      if (currentLife <= 0) continue;

      final currentPosition = Offset(
        particle.position.dx + particle.velocity.dx * particleAnimation,
        particle.position.dy +
            particle.velocity.dy * particleAnimation +
            particle.gravity * particleAnimation * particleAnimation,
      );

      final paint = Paint()
        ..color = particle.color.withValues(alpha: currentLife)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        currentPosition,
        particle.size * currentLife,
        paint,
      );
    }
  }

  void _drawDebris(Canvas canvas) {
    for (final debris in debris) {
      final currentLife = 1.0 - destructionAnimation;
      if (currentLife <= 0) continue;

      final currentPosition = Offset(
        debris.position.dx + debris.velocity.dx * destructionAnimation,
        debris.position.dy +
            debris.velocity.dy * destructionAnimation +
            200 * destructionAnimation * destructionAnimation,
      );

      canvas.save();
      canvas.translate(currentPosition.dx, currentPosition.dy);
      canvas.rotate(
          debris.rotation + debris.angularVelocity * destructionAnimation);

      final paint = Paint()
        ..color = debris.color.withValues(alpha: currentLife)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: debris.size.width * currentLife,
          height: debris.size.height * currentLife,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  void _drawEnhancedImpactEffect(Canvas canvas, Offset impact) {
    final progress = destructionAnimation;
    final maxRadius = 80.0;

    // Shockwave rings
    for (int i = 0; i < 3; i++) {
      final ringProgress = ((progress - i * 0.1).clamp(0.0, 1.0));
      final radius = maxRadius * ringProgress;
      final alpha = (1.0 - ringProgress) * 0.6;

      final paint = Paint()
        ..color =
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8 - i * 2;

      canvas.drawCircle(impact, radius, paint);
    }

    // Central explosion
    final explosionRadius = 40 * progress;
    final explosionPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.lightTheme.colorScheme.tertiary
              .withValues(alpha: 1.0 - progress),
          AppTheme.lightTheme.colorScheme.primary
              .withValues(alpha: (1.0 - progress) * 0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: impact, radius: explosionRadius));

    canvas.drawCircle(impact, explosionRadius, explosionPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Enhanced particle system
class ParticleData {
  final Offset position;
  final Offset velocity;
  final Color color;
  final double size;
  final double life;
  final double gravity;

  ParticleData({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.life,
    this.gravity = 300.0,
  });
}

class DebrisData {
  final Offset position;
  final Offset velocity;
  final Size size;
  final double rotation;
  final double angularVelocity;
  final Color color;
  final double life;

  DebrisData({
    required this.position,
    required this.velocity,
    required this.size,
    required this.rotation,
    required this.angularVelocity,
    required this.color,
    required this.life,
  });
}

// Extension for vector math
extension OffsetExtension on Offset {
  Offset get normalized {
    final dist = distance;
    return dist > 0 ? this / dist : Offset.zero;
  }
}