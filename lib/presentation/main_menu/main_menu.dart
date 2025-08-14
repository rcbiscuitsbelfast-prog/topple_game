import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/menu_button_widget.dart';
import './widgets/physics_background_widget.dart';
import './widgets/player_avatar_widget.dart';
import './widgets/social_achievements_widget.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? _playerAvatarUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPlayerData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _loadPlayerData() {
    // Load saved player avatar and game data
    // This would typically load from SharedPreferences
    setState(() {
      _playerAvatarUrl = null; // No saved avatar initially
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleTakeSelfie() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/selfie-capture-screen');
  }

  void _handlePlayGame() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/level-selection-screen');
  }

  void _handleSandboxMode() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/gameplay-screen');
  }

  void _handleCosmetics() {
    HapticFeedback.lightImpact();
    _showCosmeticsModal();
  }

  void _handleSettings() {
    HapticFeedback.lightImpact();
    _showSettingsModal();
  }

  void _handleAvatarTap() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/selfie-capture-screen');
  }

  void _showCosmeticsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 70.h,
        padding: EdgeInsets.all(6.w),
        child: Column(
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Cosmetics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 3.w,
                  mainAxisSpacing: 2.h,
                  childAspectRatio: 1,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  final cosmetics = [
                    {
                      'name': 'Party Hat',
                      'icon': 'celebration',
                      'unlocked': true
                    },
                    {
                      'name': 'Cool Glasses',
                      'icon': 'visibility',
                      'unlocked': true
                    },
                    {'name': 'Crown', 'icon': 'star', 'unlocked': false},
                    {'name': 'Mustache', 'icon': 'face', 'unlocked': true},
                    {
                      'name': 'Pirate Hat',
                      'icon': 'sailing',
                      'unlocked': false
                    },
                    {
                      'name': 'Wizard Hat',
                      'icon': 'auto_fix_high',
                      'unlocked': false
                    },
                    {
                      'name': 'Headphones',
                      'icon': 'headphones',
                      'unlocked': true
                    },
                    {'name': 'Bow Tie', 'icon': 'diamond', 'unlocked': false},
                    {
                      'name': 'Superhero Mask',
                      'icon': 'masks',
                      'unlocked': false
                    },
                  ];

                  final cosmetic = cosmetics[index];
                  final isUnlocked = cosmetic['unlocked'] as bool;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (isUnlocked) {
                        // Apply cosmetic
                      } else {
                        // Show unlock requirements
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isUnlocked
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: cosmetic['icon'] as String,
                            color: isUnlocked
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.3),
                            size: 32,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            cosmetic['name'] as String,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: isUnlocked
                                      ? AppTheme
                                          .lightTheme.colorScheme.onSurface
                                      : AppTheme
                                          .lightTheme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w500,
                                ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
            ),
            SizedBox(height: 3.h),
            _buildSettingsTile(
              icon: 'volume_up',
              title: 'Sound Effects',
              subtitle: 'Game audio and feedback',
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  // Toggle sound effects
                },
              ),
            ),
            _buildSettingsTile(
              icon: 'music_note',
              title: 'Background Music',
              subtitle: 'Menu and gameplay music',
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  // Toggle background music
                },
              ),
            ),
            _buildSettingsTile(
              icon: 'vibration',
              title: 'Haptic Feedback',
              subtitle: 'Touch vibration responses',
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  // Toggle haptic feedback
                },
              ),
            ),
            _buildSettingsTile(
              icon: 'privacy_tip',
              title: 'Privacy Policy',
              subtitle: 'Data usage and privacy',
              onTap: () {
                HapticFeedback.lightImpact();
                // Show privacy policy
              },
            ),
            _buildSettingsTile(
              icon: 'info',
              title: 'About',
              subtitle: 'Version 1.0.0',
              onTap: () {
                HapticFeedback.lightImpact();
                // Show about dialog
              },
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: AppTheme.lightTheme.colorScheme.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
            ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Physics Background
          const PhysicsBackgroundWidget(),

          // Main Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    // Top Section with Avatar
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Game Title
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Topple Game',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                    ),
                              ),
                              Text(
                                'Physics-Based Fun',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w400,
                                    ),
                              ),
                            ],
                          ),

                          // Player Avatar
                          PlayerAvatarWidget(
                            avatarImageUrl: _playerAvatarUrl,
                            onTap: _handleAvatarTap,
                            size: 60,
                          ),
                        ],
                      ),
                    ),

                    // Main Menu Buttons
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Primary Action Button
                            MenuButtonWidget(
                              title: 'Take Selfie',
                              subtitle: 'Capture your projectile',
                              icon: Icons.camera_alt,
                              type: MenuButtonType.primary,
                              onPressed: _handleTakeSelfie,
                            ),

                            SizedBox(height: 3.h),

                            // Secondary Action Buttons Row
                            Row(
                              children: [
                                Expanded(
                                  child: MenuButtonWidget(
                                    title: 'Play Game',
                                    icon: Icons.play_arrow,
                                    type: MenuButtonType.secondary,
                                    onPressed: _handlePlayGame,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: MenuButtonWidget(
                                    title: 'Sandbox',
                                    icon: Icons.build,
                                    type: MenuButtonType.secondary,
                                    onPressed: _handleSandboxMode,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 2.h),

                            // Tertiary Action Buttons Row
                            Row(
                              children: [
                                Expanded(
                                  child: MenuButtonWidget(
                                    title: 'Cosmetics',
                                    icon: Icons.face_retouching_natural,
                                    type: MenuButtonType.tertiary,
                                    onPressed: _handleCosmetics,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: MenuButtonWidget(
                                    title: 'Settings',
                                    icon: Icons.settings,
                                    type: MenuButtonType.tertiary,
                                    onPressed: _handleSettings,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Social Achievements Section
                    const SocialAchievementsWidget(),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
