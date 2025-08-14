import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

enum MenuButtonType { primary, secondary, tertiary }

class MenuButtonWidget extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final MenuButtonType type;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final double? width;

  const MenuButtonWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.type = MenuButtonType.secondary,
    this.onPressed,
    this.isEnabled = true,
    this.width,
  });

  @override
  State<MenuButtonWidget> createState() => _MenuButtonWidgetState();
}

class _MenuButtonWidgetState extends State<MenuButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: _getElevation(),
      end: _getElevation() * 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _getElevation() {
    switch (widget.type) {
      case MenuButtonType.primary:
        return 8.0;
      case MenuButtonType.secondary:
        return 4.0;
      case MenuButtonType.tertiary:
        return 2.0;
    }
  }

  Color _getBackgroundColor() {
    if (!widget.isEnabled) {
      return AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5);
    }

    switch (widget.type) {
      case MenuButtonType.primary:
        return AppTheme.lightTheme.colorScheme.primary;
      case MenuButtonType.secondary:
        return AppTheme.lightTheme.colorScheme.surface;
      case MenuButtonType.tertiary:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    if (!widget.isEnabled) {
      return AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.5);
    }

    switch (widget.type) {
      case MenuButtonType.primary:
        return Colors.white;
      case MenuButtonType.secondary:
        return AppTheme.lightTheme.colorScheme.onSurface;
      case MenuButtonType.tertiary:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  BorderSide? _getBorder() {
    if (widget.type == MenuButtonType.tertiary) {
      return BorderSide(
        color: widget.isEnabled
            ? AppTheme.lightTheme.colorScheme.primary
            : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.5),
        width: 2,
      );
    }
    return null;
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = true);
    _animationController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width ?? 80.w,
            constraints: BoxConstraints(
              minHeight: 14.h,
              maxHeight: 16.h,
            ),
            child: Material(
              elevation: _elevationAnimation.value,
              borderRadius: BorderRadius.circular(16),
              color: _getBackgroundColor(),
              shadowColor:
                  AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.3),
              child: InkWell(
                onTap: widget.isEnabled ? widget.onPressed : null,
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: _getBorder() != null
                        ? Border.fromBorderSide(_getBorder()!)
                        : null,
                    gradient: widget.type == MenuButtonType.primary
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.lightTheme.colorScheme.primary,
                              AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.8),
                            ],
                          )
                        : null,
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          CustomIconWidget(
                            iconName: widget.icon.toString().split('.').last,
                            color: _getTextColor(),
                            size:
                                widget.type == MenuButtonType.primary ? 32 : 28,
                          ),
                          SizedBox(height: 1.h),
                        ],
                        Text(
                          widget.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: _getTextColor(),
                                fontWeight:
                                    widget.type == MenuButtonType.primary
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                fontSize: widget.type == MenuButtonType.primary
                                    ? 16.sp
                                    : 14.sp,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.subtitle != null) ...[
                          SizedBox(height: 0.5.h),
                          Text(
                            widget.subtitle!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: _getTextColor().withValues(alpha: 0.7),
                                  fontSize: 11.sp,
                                ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
