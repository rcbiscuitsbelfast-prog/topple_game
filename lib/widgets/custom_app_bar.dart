import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CustomAppBarVariant {
  standard,
  gaming,
  minimal,
  withActions,
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final CustomAppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.variant = CustomAppBarVariant.standard,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.onBackPressed,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading && showBackButton,
      leading: _buildLeading(context),
      actions: _buildActions(context),
      backgroundColor: backgroundColor ?? _getBackgroundColor(theme),
      foregroundColor: foregroundColor ?? _getForegroundColor(theme),
      elevation: elevation ?? _getElevation(),
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: _getSystemOverlayStyle(theme),
      titleTextStyle: _getTitleTextStyle(theme),
      iconTheme: IconThemeData(
        color: foregroundColor ?? _getForegroundColor(theme),
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: foregroundColor ?? _getForegroundColor(theme),
        size: 24,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (!showBackButton || !automaticallyImplyLeading) return null;

    final canPop = Navigator.of(context).canPop();
    if (!canPop) return null;

    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      tooltip: 'Back',
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    switch (variant) {
      case CustomAppBarVariant.gaming:
        return [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              // Navigate to settings or show settings modal
              HapticFeedback.lightImpact();
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.person_rounded),
            onPressed: () {
              // Navigate to profile
              HapticFeedback.lightImpact();
            },
            tooltip: 'Profile',
          ),
          const SizedBox(width: 8),
        ];
      case CustomAppBarVariant.withActions:
        return actions ??
            [
              IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showMoreOptions(context);
                },
                tooltip: 'More options',
              ),
              const SizedBox(width: 8),
            ];
      default:
        return actions;
    }
  }

  Color _getBackgroundColor(ThemeData theme) {
    switch (variant) {
      case CustomAppBarVariant.gaming:
        return theme.colorScheme.surface;
      case CustomAppBarVariant.minimal:
        return Colors.transparent;
      default:
        return theme.colorScheme.surface;
    }
  }

  Color _getForegroundColor(ThemeData theme) {
    switch (variant) {
      case CustomAppBarVariant.gaming:
        return theme.colorScheme.onSurface;
      case CustomAppBarVariant.minimal:
        return theme.colorScheme.onSurface;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  double _getElevation() {
    switch (variant) {
      case CustomAppBarVariant.gaming:
        return 0;
      case CustomAppBarVariant.minimal:
        return 0;
      default:
        return 0;
    }
  }

  SystemUiOverlayStyle _getSystemOverlayStyle(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );
  }

  TextStyle? _getTitleTextStyle(ThemeData theme) {
    switch (variant) {
      case CustomAppBarVariant.gaming:
        return theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? _getForegroundColor(theme),
        );
      case CustomAppBarVariant.minimal:
        return theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: foregroundColor ?? _getForegroundColor(theme),
        );
      default:
        return theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? _getForegroundColor(theme),
        );
    }
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline_rounded),
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
