import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PhysicsBackgroundWidget extends StatefulWidget {
  const PhysicsBackgroundWidget({super.key});

  @override
  State<PhysicsBackgroundWidget> createState() =>
      _PhysicsBackgroundWidgetState();
}

class _PhysicsBackgroundWidgetState extends State<PhysicsBackgroundWidget>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _floatingController;
  late List<Particle> _particles;
  late List<FloatingObject> _floatingObjects;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    _generateFloatingObjects();
  }

  void _initializeAnimations() {
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _floatingController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
  }

  void _generateParticles() {
    _particles = List.generate(30, (index) {
      return Particle(
        x: math.Random().nextDouble(),
        y: math.Random().nextDouble(),
        size: math.Random().nextDouble() * 4 + 2,
        speed: math.Random().nextDouble() * 0.5 + 0.2,
        opacity: math.Random().nextDouble() * 0.6 + 0.2,
      );
    });
  }

  void _generateFloatingObjects() {
    _floatingObjects = List.generate(8, (index) {
      return FloatingObject(
        x: math.Random().nextDouble(),
        y: math.Random().nextDouble(),
        size: math.Random().nextDouble() * 40 + 20,
        rotationSpeed: math.Random().nextDouble() * 2 - 1,
        floatSpeed: math.Random().nextDouble() * 0.3 + 0.1,
        shape: FloatingShape
            .values[math.Random().nextInt(FloatingShape.values.length)],
      );
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.05),
            AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: ParticlePainter(
                  particles: _particles,
                  animationValue: _particleController.value,
                ),
              );
            },
          ),
          // Floating objects
          AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: FloatingObjectPainter(
                  objects: _floatingObjects,
                  animationValue: _floatingController.value,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class FloatingObject {
  final double x;
  final double y;
  final double size;
  final double rotationSpeed;
  final double floatSpeed;
  final FloatingShape shape;

  FloatingObject({
    required this.x,
    required this.y,
    required this.size,
    required this.rotationSpeed,
    required this.floatSpeed,
    required this.shape,
  });
}

enum FloatingShape { circle, square, triangle, diamond }

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = AppTheme.lightTheme.colorScheme.primary
            .withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      final x =
          (particle.x * size.width + animationValue * particle.speed * 100) %
              size.width;
      final y = (particle.y * size.height +
              math.sin(animationValue * 2 * math.pi + particle.x * 10) * 20) %
          size.height;

      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class FloatingObjectPainter extends CustomPainter {
  final List<FloatingObject> objects;
  final double animationValue;

  FloatingObjectPainter({
    required this.objects,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final obj in objects) {
      final paint = Paint()
        ..color =
            AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      final x = obj.x * size.width;
      final y = (obj.y * size.height +
              math.sin(animationValue * 2 * math.pi * obj.floatSpeed) * 30) %
          size.height;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(animationValue * 2 * math.pi * obj.rotationSpeed);

      switch (obj.shape) {
        case FloatingShape.circle:
          canvas.drawCircle(Offset.zero, obj.size / 2, paint);
          break;
        case FloatingShape.square:
          canvas.drawRect(
            Rect.fromCenter(
                center: Offset.zero, width: obj.size, height: obj.size),
            paint,
          );
          break;
        case FloatingShape.triangle:
          final path = Path();
          path.moveTo(0, -obj.size / 2);
          path.lineTo(-obj.size / 2, obj.size / 2);
          path.lineTo(obj.size / 2, obj.size / 2);
          path.close();
          canvas.drawPath(path, paint);
          break;
        case FloatingShape.diamond:
          final path = Path();
          path.moveTo(0, -obj.size / 2);
          path.lineTo(obj.size / 2, 0);
          path.lineTo(0, obj.size / 2);
          path.lineTo(-obj.size / 2, 0);
          path.close();
          canvas.drawPath(path, paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
