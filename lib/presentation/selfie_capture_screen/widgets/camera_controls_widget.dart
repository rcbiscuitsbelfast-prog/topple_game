import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CameraControlsWidget extends StatelessWidget {
  final VoidCallback? onCapture;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onCancel;
  final bool isFlashOn;
  final VoidCallback? onFlashToggle;
  final bool isGridVisible;
  final VoidCallback? onGridToggle;
  final bool isCapturing;

  const CameraControlsWidget({
    super.key,
    this.onCapture,
    this.onFlipCamera,
    this.onCancel,
    this.isFlashOn = false,
    this.onFlashToggle,
    this.isGridVisible = false,
    this.onGridToggle,
    this.isCapturing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Top controls row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildControlButton(
                    icon: isFlashOn ? 'flash_on' : 'flash_off',
                    onTap: onFlashToggle,
                    tooltip: isFlashOn ? 'Turn off flash' : 'Turn on flash',
                  ),
                  _buildControlButton(
                    icon: isGridVisible ? 'grid_on' : 'grid_off',
                    onTap: onGridToggle,
                    tooltip: isGridVisible ? 'Hide grid' : 'Show grid',
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              // Main controls row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Cancel button
                  _buildSecondaryButton(
                    icon: 'close',
                    onTap: onCancel,
                    tooltip: 'Cancel',
                  ),
                  // Capture button
                  _buildCaptureButton(),
                  // Flip camera button
                  _buildSecondaryButton(
                    icon: 'flip_camera_ios',
                    onTap: onFlipCamera,
                    tooltip: 'Switch camera',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required String icon,
    VoidCallback? onTap,
    required String tooltip,
  }) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap();
        }
      },
      child: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(5.w),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            color: Colors.white,
            size: 5.w,
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: () {
        if (onCapture != null && !isCapturing) {
          HapticFeedback.mediumImpact();
          onCapture!();
        }
      },
      child: Container(
        width: 18.w,
        height: 18.w,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isCapturing
            ? Center(
                child: SizedBox(
                  width: 6.w,
                  height: 6.w,
                  child: CircularProgressIndicator(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    strokeWidth: 3,
                  ),
                ),
              )
            : Center(
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String icon,
    VoidCallback? onTap,
    required String tooltip,
  }) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap();
        }
      },
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            color: Colors.white,
            size: 6.w,
          ),
        ),
      ),
    );
  }
}
