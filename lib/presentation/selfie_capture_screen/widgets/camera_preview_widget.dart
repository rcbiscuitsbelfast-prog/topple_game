import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController? cameraController;
  final bool showGrid;
  final bool showFaceGuide;

  const CameraPreviewWidget({
    super.key,
    this.cameraController,
    this.showGrid = false,
    this.showFaceGuide = true,
  });

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return _buildLoadingPreview();
    }

    return Stack(
      children: [
        // Camera preview
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CameraPreview(cameraController!),
        ),
        // Grid overlay
        if (showGrid) _buildGridOverlay(),
        // Face guide overlay
        if (showFaceGuide) _buildFaceGuideOverlay(),
      ],
    );
  }

  Widget _buildLoadingPreview() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 15.w,
              height: 15.w,
              child: CircularProgressIndicator(
                color: AppTheme.lightTheme.colorScheme.primary,
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Initializing Camera...',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridOverlay() {
    return CustomPaint(
      size: Size(double.infinity, double.infinity),
      painter: GridPainter(),
    );
  }

  Widget _buildFaceGuideOverlay() {
    return Center(
      child: Container(
        width: 60.w,
        height: 75.w,
        decoration: BoxDecoration(
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(30.w),
        ),
        child: Stack(
          children: [
            // Corner indicators
            Positioned(
              top: 5.w,
              left: 5.w,
              child: _buildCornerIndicator(),
            ),
            Positioned(
              top: 5.w,
              right: 5.w,
              child: _buildCornerIndicator(),
            ),
            Positioned(
              bottom: 5.w,
              left: 5.w,
              child: _buildCornerIndicator(),
            ),
            Positioned(
              bottom: 5.w,
              right: 5.w,
              child: _buildCornerIndicator(),
            ),
            // Center guide text
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Position your face\nin the oval',
                  textAlign: TextAlign.center,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerIndicator() {
    return Container(
      width: 4.w,
      height: 4.w,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    // Vertical lines
    final verticalSpacing = size.width / 3;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(verticalSpacing * i, 0),
        Offset(verticalSpacing * i, size.height),
        paint,
      );
    }

    // Horizontal lines
    final horizontalSpacing = size.height / 3;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(0, horizontalSpacing * i),
        Offset(size.width, horizontalSpacing * i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
