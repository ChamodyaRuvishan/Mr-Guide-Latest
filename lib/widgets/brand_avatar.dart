import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// BrandAvatar — Displays a user avatar with:
/// - First letter initial on a yellow/gold circle (matching the web app avatar)
/// - Or custom image URL / asset
/// - Fallback for guest ("T" for "Traveler")
/// - Optional online/active badge dot
class BrandAvatar extends StatelessWidget {
  final String? username;
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;
  final bool showBadge;

  const BrandAvatar({
    super.key,
    this.username,
    this.imageUrl,
    this.radius = 20.0,
    this.onTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveName = (username != null && username!.trim().isNotEmpty)
        ? username!.trim()
        : 'Traveler';
    final initial = effectiveName.isNotEmpty ? effectiveName[0].toUpperCase() : 'T';

    Widget avatarContent;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatarContent = CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary,
        backgroundImage: NetworkImage(imageUrl!),
      );
    } else {
      avatarContent = Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: TextStyle(
            color: AppColors.onPrimary,
            fontSize: radius * 0.95,
            fontWeight: FontWeight.w800,
            fontFamilyFallback: AppTypography.serifFallbacks,
          ),
        ),
      );
    }

    final avatarWithBadge = Stack(
      clipBehavior: Clip.none,
      children: [
        avatarContent,
        if (showBadge)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.55,
              height: radius * 0.55,
              decoration: BoxDecoration(
                color: AppColors.statusGreen,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardSurface, width: 2),
              ),
            ),
          ),
      ],
    );

    if (onTap == null) {
      return avatarWithBadge;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: avatarWithBadge,
    );
  }
}
