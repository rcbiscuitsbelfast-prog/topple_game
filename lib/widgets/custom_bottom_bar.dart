import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CustomBottomBarVariant {
  standard,
  gaming,
  floating,
  minimal,
}

class CustomBottomBar extends StatelessWidget {
  final CustomBottomBarVariant variant;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double? elevation;

  const CustomBottomBar({
    super.key,
    this.variant = CustomBottomBarVariant.gaming,
    this.currentIndex = 0,
    this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case CustomBottomBarVariant.floating:
        return _buildFloatingBottomBar(context);
      case CustomBottomBarVariant.minimal:
        return _buildMinimalBottomBar(context);
      default:
        return _buildStandardBottomBar(context);
    }
  }

  Widget _buildStandardBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final items = _getNavigationItems();

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        HapticFeedback.lightImpact();
        _handleNavigation(context, index);
        onTap?.call(index);
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      selectedItemColor: selectedItemColor ?? theme.colorScheme.primary,
      unselectedItemColor:
          unselectedItemColor ?? theme.colorScheme.onSurface.withAlpha(153),
      elevation: elevation ?? 8,
      selectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w400,
      ),
      items: items
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                activeIcon: Icon(item.activeIcon ?? item.icon),
                label: item.label,
                tooltip: item.tooltip,
              ))
          .toList(),
    );
  }

  Widget _buildFloatingBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final items = _getNavigationItems();

    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            HapticFeedback.lightImpact();
            _handleNavigation(context, index);
            onTap?.call(index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor:
              backgroundColor ?? theme.colorScheme.surface.withAlpha(242),
          selectedItemColor: selectedItemColor ?? theme.colorScheme.primary,
          unselectedItemColor:
              unselectedItemColor ?? theme.colorScheme.onSurface.withAlpha(153),
          elevation: 0,
          selectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w400,
          ),
          items: items
              .map((item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    activeIcon: Icon(item.activeIcon ?? item.icon),
                    label: item.label,
                    tooltip: item.tooltip,
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildMinimalBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final items = _getNavigationItems();

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withAlpha(51),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == currentIndex;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _handleNavigation(context, index);
              onTap?.call(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (selectedItemColor ?? theme.colorScheme.primary)
                        .withAlpha(26)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                    color: isSelected
                        ? (selectedItemColor ?? theme.colorScheme.primary)
                        : (unselectedItemColor ??
                            theme.colorScheme.onSurface.withAlpha(153)),
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? (selectedItemColor ?? theme.colorScheme.primary)
                          : (unselectedItemColor ??
                              theme.colorScheme.onSurface.withAlpha(153)),
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<_NavigationItem> _getNavigationItems() {
    return [
      _NavigationItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home',
        tooltip: 'Main Menu',
        route: '/main-menu',
      ),
      _NavigationItem(
        icon: Icons.videogame_asset_outlined,
        activeIcon: Icons.videogame_asset_rounded,
        label: 'Levels',
        tooltip: 'Level Selection',
        route: '/level-selection-screen',
      ),
      _NavigationItem(
        icon: Icons.camera_alt_outlined,
        activeIcon: Icons.camera_alt_rounded,
        label: 'Camera',
        tooltip: 'Selfie Capture',
        route: '/selfie-capture-screen',
      ),
      _NavigationItem(
        icon: Icons.play_circle_outline_rounded,
        activeIcon: Icons.play_circle_rounded,
        label: 'Play',
        tooltip: 'Gameplay',
        route: '/gameplay-screen',
      ),
    ];
  }

  void _handleNavigation(BuildContext context, int index) {
    final items = _getNavigationItems();
    if (index < items.length) {
      final route = items[index].route;
      if (route != null) {
        // Check if we're already on the target route
        final currentRoute = ModalRoute.of(context)?.settings.name;
        if (currentRoute != route) {
          Navigator.pushNamed(context, route);
        }
      }
    }
  }
}

class _NavigationItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String tooltip;
  final String? route;

  const _NavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.tooltip,
    this.route,
  });
}
