import 'package:flutter/material.dart';
import '../presentation/selfie_capture_screen/selfie_capture_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/camera_permission_screen/camera_permission_screen.dart';
import '../presentation/level_selection_screen/level_selection_screen.dart';
import '../presentation/gameplay_screen/gameplay_screen.dart';
import '../presentation/main_menu/main_menu.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String selfieCapture = '/selfie-capture-screen';
  static const String splash = '/splash-screen';
  static const String cameraPermission = '/camera-permission-screen';
  static const String levelSelection = '/level-selection-screen';
  static const String gameplay = '/gameplay-screen';
  static const String mainMenu = '/main-menu';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    selfieCapture: (context) => const SelfieCaptureScreen(),
    splash: (context) => const SplashScreen(),
    cameraPermission: (context) => const CameraPermissionScreen(),
    levelSelection: (context) => const LevelSelectionScreen(),
    gameplay: (context) => const GameplayScreen(),
    mainMenu: (context) => const MainMenu(),
    // TODO: Add your other routes here
  };
}
