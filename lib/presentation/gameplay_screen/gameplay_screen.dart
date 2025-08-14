import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/game_canvas_widget.dart';
import './widgets/game_hud_widget.dart';
import './widgets/pause_overlay_widget.dart';
import './widgets/slingshot_avatar_widget.dart';
import './widgets/victory_defeat_overlay_widget.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Game state variables
  bool _isPaused = false;
  bool _isLaunching = false;
  bool _gameEnded = false;
  bool _isVictory = false;
  int _currentScore = 0;
  int _remainingShots = 3;
  double _destructionPercentage = 0.0;
  int _starsEarned = 0;

  // Enhanced physics and interaction variables
  Offset? _dragStart;
  Offset? _dragEnd;
  bool _showTrajectory = false;
  double _launchPower = 0.0;
  double _launchAngle = 0.0;
  double _maxDragDistance = 150.0;

  // Slingshot mechanics
  bool _isDragging = false;
  Offset _slingshotPosition = const Offset(100, 400);
  late AnimationController _slingshotController;
  late Animation<double> _slingshotAnimation;

  // Game objects with household items
  List<HouseholdGameObject> _gameObjects = [];
  ProjectileData? _activeProjectile;
  String? _selfieImagePath;

  // Physics simulation
  Timer? _physicsTimer;
  Timer? _gameTimer;
  late AnimationController _backgroundController;

  // Device tilt for enhanced control
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double _deviceTilt = 0.0;

  // Enhanced household object data with realistic physics
  final List<Map<String, dynamic>> _householdLevelData = [
    {
      "id": 1,
      "name": "Kitchen Chaos",
      "theme": "kitchen",
      "targetDestruction": 70.0,
      "maxShots": 3,
      "objects": [
        // Stack of dishes {"type": "plate", "x": 250.0, "y": 350.0, "rotation": 0.0, "material": "ceramic"},
        {
          "type": "plate",
          "x": 250.0,
          "y": 320.0,
          "rotation": 0.05,
          "material": "ceramic"
        },
        {
          "type": "plate",
          "x": 250.0,
          "y": 290.0,
          "rotation": -0.03,
          "material": "ceramic"
        },
        {
          "type": "cup",
          "x": 250.0,
          "y": 260.0,
          "rotation": 0.0,
          "material": "ceramic"
        },

// Kitchen utensils tower {"type": "bottle", "x": 300.0, "y": 340.0, "rotation": 0.0, "material": "glass"},
        {
          "type": "pan",
          "x": 300.0,
          "y": 300.0,
          "rotation": 0.1,
          "material": "metal"
        },
        {
          "type": "bowl",
          "x": 300.0,
          "y": 270.0,
          "rotation": 0.0,
          "material": "ceramic"
        },

// Fragile tower {"type": "glass", "x": 200.0, "y": 350.0, "rotation": 0.0, "material": "glass"},
        {
          "type": "glass",
          "x": 200.0,
          "y": 320.0,
          "rotation": 0.02,
          "material": "glass"
        },
        {
          "type": "vase",
          "x": 200.0,
          "y": 280.0,
          "rotation": 0.0,
          "material": "glass"
        },
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeGame();
    _setupAnimations();
    _loadMockSelfie();
    _startPhysicsSimulation();
    _setupDeviceMotion();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gameTimer?.cancel();
    _physicsTimer?.cancel();
    _backgroundController.dispose();
    _slingshotController.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (!_isPaused && !_gameEnded) {
        _pauseGame();
      }
    }
  }

  void _initializeGame() {
    final level = _householdLevelData.first;
    _remainingShots = (level["maxShots"] as int);
    _gameObjects = _createHouseholdObjects(level["objects"] as List);
    _currentScore = 0;
    _destructionPercentage = 0.0;
    _gameEnded = false;
    _isVictory = false;
    _starsEarned = 0;
    _activeProjectile = null;
  }

  void _setupAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _backgroundController.repeat();

    _slingshotController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slingshotAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slingshotController,
      curve: Curves.elasticOut,
    ));
  }

  void _loadMockSelfie() {
    _selfieImagePath = "assets/images/1000002161-1755189011613.jpg";
  }

  void _startPhysicsSimulation() {
    _physicsTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!_isPaused && !_gameEnded) {
        _updatePhysics();
      }
    });
  }

  void _setupDeviceMotion() {
    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        if (mounted && _isDragging) {
          setState(() {
            // Use device tilt to fine-tune aim
            _deviceTilt = event.x.clamp(-2.0, 2.0) * 0.1;
          });
        }
      },
    );
  }

  void _updatePhysics() {
    if (_activeProjectile != null) {
      setState(() {
        // Update projectile position
        _activeProjectile!.position += _activeProjectile!.velocity * 0.016;
        _activeProjectile!.velocity += const Offset(0, 300) * 0.016; // Gravity

        // Check for collisions
        _checkCollisions();

        // Remove if out of bounds
        if (_activeProjectile!.position.dy > 600 ||
            _activeProjectile!.position.dx > 500) {
          _activeProjectile = null;
          _checkGameEnd();
        }
      });
    }

    // Update destroyed objects physics
    for (var obj in _gameObjects) {
      if (obj.isDestroyed && obj.velocity.distance > 0.1) {
        obj.position += obj.velocity * 0.016;
        obj.velocity *= 0.98; // Friction
        obj.rotation += obj.angularVelocity * 0.016;
        obj.angularVelocity *= 0.95;
      }
    }
  }

  void _checkCollisions() {
    if (_activeProjectile == null) return;

    for (int i = 0; i < _gameObjects.length; i++) {
      final obj = _gameObjects[i];
      if (obj.isDestroyed) continue;

      final distance = (_activeProjectile!.position - obj.position).distance;
      final collisionRadius = obj.size.width / 2 + 15;

      if (distance < collisionRadius) {
        _handleCollision(i);
        break;
      }
    }
  }

  void _handleCollision(int objectIndex) {
    final obj = _gameObjects[objectIndex];
    final impactForce = _activeProjectile!.velocity.distance;

    // Calculate destruction based on material and impact force
    final destructionChance = _calculateDestructionChance(obj, impactForce);

    if (math.Random().nextDouble() < destructionChance) {
      setState(() {
        obj.isDestroyed = true;
        obj.velocity = _activeProjectile!.velocity * 0.3;
        obj.angularVelocity = (math.Random().nextDouble() - 0.5) * 10;

        _currentScore += obj.getScoreValue();
      });

      // Chain reaction for fragile items
      _checkChainReaction(objectIndex, impactForce);
      HapticFeedback.mediumImpact();
    } else {
      // Object hit but not destroyed, just moved
      setState(() {
        obj.velocity = _activeProjectile!.velocity * 0.2;
        obj.angularVelocity = (math.Random().nextDouble() - 0.5) * 5;
      });
      HapticFeedback.lightImpact();
    }

    _activeProjectile = null;
    _updateDestructionPercentage();
    _checkGameEnd();
  }

  double _calculateDestructionChance(
      HouseholdGameObject obj, double impactForce) {
    double baseChance = (impactForce / 200).clamp(0.0, 1.0);

    switch (obj.material) {
      case "glass":
        return (baseChance * 1.5).clamp(0.0, 1.0);
      case "ceramic":
        return (baseChance * 1.2).clamp(0.0, 1.0);
      case "plastic":
        return (baseChance * 0.8).clamp(0.0, 1.0);
      case "metal":
        return (baseChance * 0.6).clamp(0.0, 1.0);
      default:
        return baseChance;
    }
  }

  void _checkChainReaction(int hitIndex, double force) {
    final hitObj = _gameObjects[hitIndex];
    final chainRadius = 80.0;

    for (int i = 0; i < _gameObjects.length; i++) {
      if (i == hitIndex || _gameObjects[i].isDestroyed) continue;

      final distance = (hitObj.position - _gameObjects[i].position).distance;
      if (distance < chainRadius && _gameObjects[i].material == "glass") {
        final chainChance = ((chainRadius - distance) / chainRadius) * 0.3;
        if (math.Random().nextDouble() < chainChance) {
          setState(() {
            _gameObjects[i].isDestroyed = true;
            _gameObjects[i].velocity = Offset(
              (math.Random().nextDouble() - 0.5) * 100,
              -math.Random().nextDouble() * 50,
            );
            _currentScore += _gameObjects[i].getScoreValue();
          });
        }
      }
    }
  }

  void _updateDestructionPercentage() {
    final destroyed = _gameObjects.where((obj) => obj.isDestroyed).length;
    _destructionPercentage = (destroyed / _gameObjects.length) * 100;
  }

  List<HouseholdGameObject> _createHouseholdObjects(List<dynamic> objectsData) {
    return (objectsData).map((obj) {
      final objMap = obj as Map<String, dynamic>;
      return HouseholdGameObject(
        type: objMap["type"] as String,
        position: Offset(objMap["x"] as double, objMap["y"] as double),
        rotation: objMap["rotation"] as double,
        material: objMap["material"] as String,
      );
    }).toList();
  }

  void _onSlingshotDragStart(Offset position) {
    if (_isPaused || _gameEnded || _isLaunching || _remainingShots <= 0) return;

    final slingshotArea = Rect.fromCenter(
      center: _slingshotPosition,
      width: 100,
      height: 100,
    );

    if (slingshotArea.contains(position)) {
      setState(() {
        _dragStart = position;
        _isDragging = true;
        _showTrajectory = false;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _onSlingshotDragUpdate(Offset position) {
    if (!_isDragging || _dragStart == null) return;

    final delta = position - _dragStart!;
    final clampedDistance = delta.distance.clamp(0.0, _maxDragDistance);
    final direction = delta.distance > 0 ? delta / delta.distance : Offset.zero;
    final clampedDelta = direction * clampedDistance;

    setState(() {
      _dragEnd = _dragStart! + clampedDelta;
      _showTrajectory = true;

      // Calculate power and angle with device tilt influence
      _launchPower = (clampedDistance / _maxDragDistance).clamp(0.0, 1.0);
      _launchAngle = (-clampedDelta).direction + _deviceTilt;
    });

    // Haptic feedback for optimal power
    if (_launchPower > 0.7 && _launchPower < 0.9) {
      HapticFeedback.selectionClick();
    }
  }

  void _onSlingshotDragEnd(Offset position) {
    if (!_isDragging || _dragStart == null) return;

    _launchProjectile();
  }

  void _launchProjectile() {
    if (_remainingShots <= 0 || _launchPower < 0.1) return;

    final launchVelocity = Offset(
      math.cos(_launchAngle) * _launchPower * 400,
      math.sin(_launchAngle) * _launchPower * 400,
    );

    setState(() {
      _isLaunching = true;
      _remainingShots--;
      _showTrajectory = false;
      _isDragging = false;

      _activeProjectile = ProjectileData(
        position: _slingshotPosition + const Offset(30, -20),
        velocity: launchVelocity,
        selfieImagePath: _selfieImagePath,
      );

      _dragStart = null;
      _dragEnd = null;
    });

    _slingshotController.forward().then((_) {
      _slingshotController.reverse();
    });

    HapticFeedback.heavyImpact();

    // Stop being "launching" after animation
    Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLaunching = false;
        });
      }
    });
  }

  void _checkGameEnd() {
    final targetDestruction =
        _householdLevelData.first["targetDestruction"] as double;

    if (_destructionPercentage >= targetDestruction) {
      _starsEarned = _calculateStars();
      setState(() {
        _isVictory = true;
        _gameEnded = true;
      });
      HapticFeedback.heavyImpact();
    } else if (_remainingShots <= 0 && _activeProjectile == null) {
      setState(() {
        _isVictory = false;
        _gameEnded = true;
      });
      HapticFeedback.lightImpact();
    }
  }

  int _calculateStars() {
    if (_destructionPercentage >= 90) return 3;
    if (_destructionPercentage >= 80) return 2;
    return 1;
  }

  void _pauseGame() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeGame() {
    setState(() {
      _isPaused = false;
    });
  }

  void _restartGame() {
    setState(() {
      _isPaused = false;
      _gameEnded = false;
    });
    _initializeGame();
  }

  void _quitToMenu() {
    Navigator.pushReplacementNamed(context, '/main-menu');
  }

  void _nextLevel() {
    _restartGame();
  }

  void _shareScore() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Score shared! ${_currentScore} points with ${_destructionPercentage.toStringAsFixed(0)}% destruction!'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Container(
          width: 100.w,
          height: 100.h,
          child: Stack(
            children: [
              // Game Canvas
              GameCanvasWidget(
                onDragStart: _onSlingshotDragStart,
                onDragUpdate: _onSlingshotDragUpdate,
                onDragEnd: _onSlingshotDragEnd,
                isLaunching: _isLaunching,
                destructionPercentage: _destructionPercentage,
                gameObjects: _gameObjects,
                trajectoryStart: _dragStart,
                trajectoryEnd: _dragEnd,
                showTrajectory: _showTrajectory,
                slingshotPosition: _slingshotPosition,
                activeProjectile: _activeProjectile,
                launchPower: _launchPower,
              ),

              // Enhanced Slingshot Avatar
              AnimatedBuilder(
                animation: _slingshotAnimation,
                builder: (context, child) {
                  return SlingshotAvatarWidget(
                    selfieImagePath: _selfieImagePath,
                    isLaunching: _isLaunching,
                    power: _launchPower,
                    angle: _launchAngle,
                    position: _slingshotPosition,
                    isDragging: _isDragging,
                    slingshotStretch: _slingshotAnimation.value,
                    onTap: () {
                      if (!_isPaused && !_gameEnded) {
                        Navigator.pushNamed(context, '/selfie-capture-screen');
                      }
                    },
                  );
                },
              ),

              // Game HUD
              GameHudWidget(
                currentScore: _currentScore,
                remainingShots: _remainingShots,
                destructionPercentage: _destructionPercentage,
                onPause: _pauseGame,
                isPaused: _isPaused,
              ),

              // Pause Overlay
              PauseOverlayWidget(
                isVisible: _isPaused,
                onResume: _resumeGame,
                onRestart: _restartGame,
                onQuit: _quitToMenu,
              ),

              // Victory/Defeat Overlay
              VictoryDefeatOverlayWidget(
                isVisible: _gameEnded,
                isVictory: _isVictory,
                finalScore: _currentScore,
                destructionPercentage: _destructionPercentage,
                starsEarned: _starsEarned,
                onNextLevel: _nextLevel,
                onRestart: _restartGame,
                onMainMenu: _quitToMenu,
                onShare: _shareScore,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced household game object class
class HouseholdGameObject {
  final String type;
  Offset position;
  double rotation;
  final String material;
  bool isDestroyed;
  Offset velocity;
  double angularVelocity;
  final Size size;
  final Color color;

  HouseholdGameObject({
    required this.type,
    required this.position,
    required this.rotation,
    required this.material,
    this.isDestroyed = false,
    this.velocity = Offset.zero,
    this.angularVelocity = 0.0,
  })  : size = _getSizeForType(type),
        color = _getColorForType(type, material);

  static Size _getSizeForType(String type) {
    switch (type) {
      case "plate":
        return const Size(60, 8);
      case "cup":
        return const Size(30, 40);
      case "bowl":
        return const Size(50, 25);
      case "glass":
        return const Size(25, 50);
      case "bottle":
        return const Size(20, 60);
      case "pan":
        return const Size(80, 15);
      case "vase":
        return const Size(35, 70);
      default:
        return const Size(40, 40);
    }
  }

  static Color _getColorForType(String type, String material) {
    switch (material) {
      case "glass":
        return const Color(0xFFE3F2FD);
      case "ceramic":
        return const Color(0xFFFFF8E1);
      case "metal":
        return const Color(0xFFECEFF1);
      case "plastic":
        return const Color(0xFFE8F5E8);
      default:
        return const Color(0xFFFFE0B2);
    }
  }

  int getScoreValue() {
    int baseScore = 10;
    switch (type) {
      case "vase":
        baseScore = 50;
        break;
      case "glass":
        baseScore = 30;
        break;
      case "bottle":
        baseScore = 25;
        break;
      case "plate":
        baseScore = 15;
        break;
      case "cup":
        baseScore = 20;
        break;
      case "bowl":
        baseScore = 15;
        break;
      case "pan":
        baseScore = 10;
        break;
    }

    // Bonus for fragile materials
    if (material == "glass") {
      baseScore = (baseScore * 1.5).round();
    }

    return baseScore;
  }
}

// Projectile data class for the face projectile
class ProjectileData {
  Offset position;
  Offset velocity;
  final String? selfieImagePath;
  double rotation;

  ProjectileData({
    required this.position,
    required this.velocity,
    this.selfieImagePath,
    this.rotation = 0.0,
  });
}
