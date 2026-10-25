import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'app_card.dart';
import 'icon_badge.dart';

enum FeatureCardLayout {
  fullWidth, // Horizontal row layout
  compact, // Vertical grid card layout
}

/// FeatureCard — Rich card featuring an IconBadge, serif/sans title,
/// short description, and an arrow/action icon.
/// Supports both full-width list row and compact 2-column grid representations.
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final FeatureCardLayout layout;
  final String? badgeText;
  final IconData arrowIcon;
  final Color? iconBadgeBg;
  final Color? iconColor;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
    this.layout = FeatureCardLayout.fullWidth,
    this.badgeText,
    this.arrowIcon = Icons.arrow_forward_rounded,
    this.iconBadgeBg,
    this.iconColor,
  });

  const FeatureCard.compact({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
    this.badgeText,
    this.arrowIcon = Icons.north_east_rounded,
    this.iconBadgeBg,
    this.iconColor,
  }) : layout = FeatureCardLayout.compact;

  @override
  Widget build(BuildContext context) {
    if (layout == FeatureCardLayout.compact) {
      return _buildCompactCard();
    }
    return _buildFullWidthCard();
  }

  Widget _buildFullWidthCard() {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconBadge(
            icon: icon,
            backgroundColor: iconBadgeBg,
            iconColor: iconColor,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: AppTypography.titleSans,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badgeText != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _buildPillBadge(badgeText!),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTypography.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Icon(
            arrowIcon,
            size: 18,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCard() {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconBadge.compact(
                icon: icon,
                backgroundColor: iconBadgeBg,
                iconColor: iconColor,
              ),
              Icon(
                arrowIcon,
                size: 18,
                color: AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (badgeText != null) ...[
                _buildPillBadge(badgeText!),
                const SizedBox(height: AppSpacing.xs),
              ],
              Text(
                title,
                style: AppTypography.titleSans.copyWith(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: AppTypography.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
