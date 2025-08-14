import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _loadingController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _loadingProgress;

  bool _isInitializing = true;
  String _loadingText = "Initializing...";
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    // Logo bounce animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    // Loading progress animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _loadingProgress = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    // Start logo animation
    _logoController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Start loading animation after logo appears
      await Future.delayed(const Duration(milliseconds: 800));
      _loadingController.forward();

      // Step 1: Check camera permissions
      _updateProgress(0.2, "Checking camera permissions...");
      await Future.delayed(const Duration(milliseconds: 300));

      final cameraPermission = await _requestCameraPermission();

      // Step 2: Initialize physics engine
      _updateProgress(0.4, "Loading physics engine...");
      await Future.delayed(const Duration(milliseconds: 400));
      await _initializePhysicsEngine();

      // Step 3: Prepare facial detection models
      _updateProgress(0.6, "Preparing facial detection...");
      await Future.delayed(const Duration(milliseconds: 400));
      await _prepareFacialDetection();

      // Step 4: Check device capabilities
      _updateProgress(0.8, "Checking device capabilities...");
      await Future.delayed(const Duration(milliseconds: 300));
      final deviceCapable = await _checkDeviceCapabilities();

      // Step 5: Complete initialization
      _updateProgress(1.0, "Ready to play!");
      await Future.delayed(const Duration(milliseconds: 300));

      // Haptic feedback on completion
      HapticFeedback.lightImpact();

      // Navigate based on permissions and capabilities
      if (cameraPermission && deviceCapable) {
        _navigateToMainMenu();
      } else {
        _navigateToCameraPermission();
      }
    } catch (e) {
      // Handle initialization errors gracefully
      _updateProgress(1.0, "Initialization complete");
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateToMainMenu();
    }
  }

  Future<bool> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      if (status.isGranted) {
        return true;
      } else if (status.isDenied) {
        final result = await Permission.camera.request();
        return result.isGranted;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _initializePhysicsEngine() async {
    // Simulate physics engine initialization
    // In real implementation, this would load physics libraries
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> _prepareFacialDetection() async {
    // Simulate facial detection model loading
    // In real implementation, this would load ML models
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<bool> _checkDeviceCapabilities() async {
    try {
      // Check for front-facing camera
      // Check available storage
      // Check processing power
      await Future.delayed(const Duration(milliseconds: 200));
      return true;
    } catch (e) {
      return false;
    }
  }

  void _updateProgress(double progress, String text) {
    if (mounted) {
      setState(() {
        _progress = progress;
        _loadingText = text;
      });
    }
  }

  void _navigateToMainMenu() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/main-menu');
    }
  }

  void _navigateToCameraPermission() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/camera-permission-screen');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hide system status bar for full-screen experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightTheme.colorScheme.primary,
              AppTheme.lightTheme.colorScheme.secondary,
              AppTheme.lightTheme.colorScheme.tertiary,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spacer to center content
              const Spacer(flex: 2),

              // Animated Logo Section
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: 80.w,
                        height: 25.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Game Logo Icon
                            Container(
                              width: 20.w,
                              height: 10.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: CustomIconWidget(
                                iconName: 'sports_baseball',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 12.w,
                              ),
                            ),

                            SizedBox(height: 2.h),

                            // Game Title
                            Text(
                              'TOPPLE',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 1.h),

                            // Subtitle
                            Text(
                              'Physics Game',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 1,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const Spacer(flex: 1),

              // Loading Section
              AnimatedBuilder(
                animation: _loadingController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _loadingController.value,
                    child: Container(
                      width: 70.w,
                      padding:
                          EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                      child: Column(
                        children: [
                          // Loading Text
                          Text(
                            _loadingText,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 2.h),

                          // Progress Bar
                          Container(
                            width: double.infinity,
                            height: 0.8.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: _progress,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 1.h),

                          // Progress Percentage
                          Text(
                            '${(_progress * 100).toInt()}%',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const Spacer(flex: 2),

              // Bottom Branding
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Column(
                  children: [
                    Text(
                      'Powered by Flutter',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w300,
                          ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'v1.0.0',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w300,
                          ),
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
