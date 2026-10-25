import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/user.dart';
import 'brand_avatar.dart';
import 'brand_logo.dart';
import 'pill_button.dart';
import 'status_pill.dart';

/// HomeHeader — Modern header replacing the old fixed AppBar.
/// - Logged in: Avatar + "Hi, `<username>`" (name in yellow) + "Live trip" StatusPill.
/// - Guest: BrandLogo + compact "Login" & "Register" buttons.
/// Designed to sit within the scrollable content or sliver with 0 wasted space.
class HomeHeader extends StatelessWidget {
  final User? user;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onLogout;
  final VoidCallback onOpenLiveTrip;

  const HomeHeader({
    super.key,
    required this.user,
    required this.onLogin,
    required this.onRegister,
    required this.onLogout,
    required this.onOpenLiveTrip,
  });

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return _buildLoggedInHeader(context, user!);
    }
    return _buildGuestHeader(context);
  }

  Widget _buildLoggedInHeader(BuildContext context, User currentUser) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: User avatar + Greeting
          Flexible(
            child: InkWell(
              onTap: () => _showUserProfileSheet(context, currentUser),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BrandAvatar(
                      username: currentUser.username,
                      radius: 20,
                      showBadge: true,
                    ),
                    const SizedBox(width: AppSpacing.sm + 2),
                    Flexible(
                      child: RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Hi, ',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            TextSpan(
                              text: currentUser.username,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Right: "Live trip" StatusPill
          StatusPill(
            onTap: onOpenLiveTrip,
            isLive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildGuestHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Brand Logo
          const BrandLogo.compact(),
          // Right: Compact Login & Register buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PillButton.secondary(
                label: 'Login',
                size: PillButtonSize.small,
                onPressed: onLogin,
              ),
              const SizedBox(width: AppSpacing.sm),
              PillButton(
                label: 'Register',
                size: PillButtonSize.small,
                onPressed: onRegister,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUserProfileSheet(BuildContext context, User currentUser) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.hero)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    BrandAvatar(
                      username: currentUser.username,
                      radius: 28,
                      showBadge: true,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser.username,
                            style: AppTypography.titleSans,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentUser.email,
                            style: AppTypography.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (currentUser.role != null &&
                              currentUser.role!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                currentUser.role!.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    onLogout();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
