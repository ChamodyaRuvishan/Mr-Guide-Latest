import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// AppBottomNavBar — Custom floating, rounded bottom navigation bar
/// with soft shadow/glow, 4 main tabs, and a raised center circular yellow FAB
/// for "Ask AI".
///
/// Slots:
/// 0: Home (Icons.home_rounded)
/// 1: Explore (Icons.explore_rounded)
/// [CENTER RAISED FAB]: Ask AI (Icons.auto_awesome_rounded)
/// 2: Find a guide (Icons.people_alt_rounded)
/// 3: About (Icons.info_outline_rounded)
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAskAi;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAskAi,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screenHorizontal,
        right: AppSpacing.screenHorizontal,
        bottom: bottomInset > 0 ? bottomInset : AppSpacing.md,
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Floating bar container
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.navSurface,
              borderRadius: BorderRadius.circular(AppRadius.hero),
              border: Border.all(
                color: AppColors.cardBorder,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 0. Home
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'Home',
                ),
                // 1. Explore
                _buildNavItem(
                  index: 1,
                  icon: Icons.explore_rounded,
                  label: 'Explore',
                ),
                // Center Gap for Raised FAB
                const SizedBox(width: 58),
                // 2. Guides
                _buildNavItem(
                  index: 2,
                  icon: Icons.people_alt_rounded,
                  label: 'Guides',
                ),
                // 3. About
                _buildNavItem(
                  index: 3,
                  icon: Icons.info_outline_rounded,
                  label: 'About',
                ),
              ],
            ),
          ),

          // CENTER RAISED YELLOW CIRCULAR FAB (Ask AI)
          Positioned(
            top: -16,
            child: GestureDetector(
              onTap: onAskAi,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.background,
                        width: 3.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.45),
                          blurRadius: 18,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 25,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Ask AI',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isActive = currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTabSelected(index),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          splashColor: AppColors.primary.withValues(alpha: 0.12),
          highlightColor: Colors.white.withValues(alpha: 0.04),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  size: 23,
                  color: isActive ? AppColors.primary : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppColors.primary : AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              // Active dot/pill indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 12 : 0,
                height: 2.5,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
