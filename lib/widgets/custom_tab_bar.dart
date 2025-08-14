import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CustomTabBarVariant {
  standard,
  gaming,
  pills,
  underline,
  segmented,
}

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<CustomTab> tabs;
  final TabController? controller;
  final CustomTabBarVariant variant;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? indicatorColor;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;
  final ValueChanged<int>? onTap;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.variant = CustomTabBarVariant.gaming,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorColor,
    this.isScrollable = false,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (variant) {
      case CustomTabBarVariant.pills:
        return _buildPillsTabBar(context);
      case CustomTabBarVariant.segmented:
        return _buildSegmentedTabBar(context);
      case CustomTabBarVariant.underline:
        return _buildUnderlineTabBar(context);
      case CustomTabBarVariant.gaming:
        return _buildGamingTabBar(context);
      default:
        return _buildStandardTabBar(context);
    }
  }

  Widget _buildStandardTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: backgroundColor ?? theme.colorScheme.surface,
      padding: padding,
      child: TabBar(
        controller: controller,
        tabs: tabs
            .map((tab) => Tab(
                  icon: tab.icon != null ? Icon(tab.icon) : null,
                  text: tab.text,
                  child: tab.child,
                ))
            .toList(),
        isScrollable: isScrollable,
        labelColor: selectedColor ?? theme.colorScheme.primary,
        unselectedLabelColor:
            unselectedColor ?? theme.colorScheme.onSurface.withAlpha(153),
        indicatorColor: indicatorColor ?? theme.colorScheme.primary,
        indicatorWeight: 3,
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        onTap: (index) {
          HapticFeedback.lightImpact();
          _handleTabTap(context, index);
          onTap?.call(index);
        },
      ),
    );
  }

  Widget _buildGamingTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withAlpha(26),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      padding: padding,
      child: TabBar(
        controller: controller,
        tabs: tabs
            .map((tab) => Tab(
                  icon: tab.icon != null ? Icon(tab.icon, size: 24) : null,
                  text: tab.text,
                  child: tab.child,
                ))
            .toList(),
        isScrollable: isScrollable,
        labelColor: selectedColor ?? theme.colorScheme.primary,
        unselectedLabelColor:
            unselectedColor ?? theme.colorScheme.onSurface.withAlpha(153),
        indicatorColor: indicatorColor ?? theme.colorScheme.primary,
        indicatorWeight: 4,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: (indicatorColor ?? theme.colorScheme.primary).withAlpha(26),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            bottom: BorderSide(
              color: indicatorColor ?? theme.colorScheme.primary,
              width: 3,
            ),
          ),
        ),
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        onTap: (index) {
          HapticFeedback.lightImpact();
          _handleTabTap(context, index);
          onTap?.call(index);
        },
      ),
    );
  }

  Widget _buildPillsTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: backgroundColor ?? theme.colorScheme.surface,
      padding: padding ?? const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = controller?.index == index;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  controller?.animateTo(index);
                  _handleTabTap(context, index);
                  onTap?.call(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (selectedColor ?? theme.colorScheme.primary)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? (selectedColor ?? theme.colorScheme.primary)
                          : theme.colorScheme.outline.withAlpha(128),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (tab.icon != null) ...[
                        Icon(
                          tab.icon,
                          size: 18,
                          color: isSelected
                              ? Colors.white
                              : (unselectedColor ??
                                  theme.colorScheme.onSurface.withAlpha(153)),
                        ),
                        if (tab.text != null) const SizedBox(width: 8),
                      ],
                      if (tab.text != null)
                        Text(
                          tab.text!,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: isSelected
                                ? Colors.white
                                : (unselectedColor ??
                                    theme.colorScheme.onSurface.withAlpha(153)),
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSegmentedTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: backgroundColor ?? theme.colorScheme.surface,
      padding: padding ?? const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withAlpha(51),
            width: 1,
          ),
        ),
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = controller?.index == index;
            final isFirst = index == 0;
            final isLast = index == tabs.length - 1;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  controller?.animateTo(index);
                  _handleTabTap(context, index);
                  onTap?.call(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (selectedColor ?? theme.colorScheme.primary)
                        : Colors.transparent,
                    borderRadius: BorderRadius.horizontal(
                      left: isFirst ? const Radius.circular(12) : Radius.zero,
                      right: isLast ? const Radius.circular(12) : Radius.zero,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (tab.icon != null) ...[
                        Icon(
                          tab.icon,
                          size: 18,
                          color: isSelected
                              ? Colors.white
                              : (unselectedColor ??
                                  theme.colorScheme.onSurface.withAlpha(153)),
                        ),
                        if (tab.text != null) const SizedBox(width: 8),
                      ],
                      if (tab.text != null)
                        Text(
                          tab.text!,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: isSelected
                                ? Colors.white
                                : (unselectedColor ??
                                    theme.colorScheme.onSurface.withAlpha(153)),
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildUnderlineTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: backgroundColor ?? theme.colorScheme.surface,
      padding: padding,
      child: TabBar(
        controller: controller,
        tabs: tabs
            .map((tab) => Tab(
                  icon: tab.icon != null ? Icon(tab.icon) : null,
                  text: tab.text,
                  child: tab.child,
                ))
            .toList(),
        isScrollable: isScrollable,
        labelColor: selectedColor ?? theme.colorScheme.primary,
        unselectedLabelColor:
            unselectedColor ?? theme.colorScheme.onSurface.withAlpha(153),
        indicatorColor: indicatorColor ?? theme.colorScheme.primary,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        onTap: (index) {
          HapticFeedback.lightImpact();
          _handleTabTap(context, index);
          onTap?.call(index);
        },
      ),
    );
  }

  void _handleTabTap(BuildContext context, int index) {
    // Handle navigation based on tab selection if needed
    // This can be customized based on specific requirements
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomTab {
  final String? text;
  final IconData? icon;
  final Widget? child;

  const CustomTab({
    this.text,
    this.icon,
    this.child,
  }) : assert(text != null || icon != null || child != null);
}
